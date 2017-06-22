//
//  BoardView.swift
//  WordCrusher
//
//  Created by George Madrid on 6/21/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Cocoa

fileprivate let pi: CGFloat = 3.14159265359
fileprivate let rad3 = sqrt(3.0) as CGFloat
fileprivate let rad3Over2 = sqrt(3.0) / 2.0 as CGFloat
fileprivate let piOver3 = pi / 3.0

fileprivate let inset = NSEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)

class BoardView: NSView {
  let rows = 10
  let cols = 9
  let radius = 25.0 as CGFloat
  
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
  
  private func centersForRow(at start: CGPoint, cols count: Int) -> [CGPoint] {
    return (0..<count).map({ i -> CGPoint in
      CGPoint(x: start.x + CGFloat(i) * 1.5 * radius,
              y: start.y + CGFloat(i % 2) * -rad3Over2 * radius)
    })
  }
  
  private func copyRowCenters(_ centers: [CGPoint], count: Int) -> [CGPoint] {
    return Array((0..<count).map { row -> [CGPoint] in
      (0..<centers.count).map { col -> CGPoint in
        CGPoint(x: centers[col].x,
                y: centers[col].y + CGFloat(row * 2) * rad3Over2 * radius)
      }
      }
      .joined())
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    guard let context = NSGraphicsContext.current()?.cgContext else {
      return
    }
    
    // Move the origin to upper-left.
    context.scaleBy(x: 1.0, y: -1.0)
    context.translateBy(x: 0, y: -self.bounds.size.height)
    
    let firstHexCenter = CGPoint(x: inset.left + radius, y: inset.top + rad3 * radius)
    let firstRowCenters = centersForRow(at: firstHexCenter, cols: cols)
    let allCenters = copyRowCenters(firstRowCenters, count: rows)
    let hexPaths = allCenters.map { pathForPoly(points: hexPoints(at: $0, radius: radius)) }

    hexPaths.forEach { path in
      context.addPath(path)
      context.strokePath()
    }
  }
  
}
