//
//  BoardView.swift
//  WordCrusher
//
//  Created by George Madrid on 6/21/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Cocoa

class BoardView: NSView {
  private static let pi: CGFloat = 3.14159265359
  private static let rad3 = sqrt(3.0) as CGFloat
  private static let rad3Over2 = rad3 / 2.0 as CGFloat
  private static let piOver3 = pi / 3.0
  
  private static var corners =
    [ 0, piOver3, 2 * piOver3, 3 * piOver3, 4 * piOver3, 5 * piOver3 ].map { rad in
      return ( CGPoint(x: cos(rad), y: sin(rad)) )
    }
  
  private func hexPoints(at center: CGPoint, radius: CGFloat) -> [CGPoint] {
    return BoardView.corners.map { pt in
      return CGPoint(x: radius * pt.x + center.x, y: radius * pt.y + center.y)
    }
  }
  
  private func pathForPoly(points: [CGPoint]) -> CGPath {
    let path = CGMutablePath()
    path.move(to: points[0])
    for i in 1...points.count {
      path.addLine(to: points[i % points.count])
    }
    return path
  }
  
  private func renderHex(in context: CGContext, at center: CGPoint, radius: CGFloat) {
    context.addPath(pathForPoly(points: hexPoints(at: center, radius: radius)))
    context.strokePath()
  }
  
  private func renderHexLine(in context: CGContext, at startCenter: CGPoint, radius: CGFloat, count: Int) {
    for i in 0..<count {
      let center = CGPoint(x: startCenter.x + CGFloat(i) * 1.5 * radius,
                           y: startCenter.y + CGFloat(i % 2) * -BoardView.rad3Over2 * radius)
      renderHex(in: context, at: center, radius: radius)
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    guard let context = NSGraphicsContext.current()?.cgContext else {
      return
    }
    
    let testR: CGFloat = 30.0
    let testCenter = CGPoint(x: 50.0, y: 60.0)
    
    for i in 0..<5 {
      let center = CGPoint(x: testCenter.x, y: testCenter.y + BoardView.rad3 * testR * CGFloat(i))
      renderHexLine(in: context, at: center, radius: testR, count: 6)
    }
  }
  
}
