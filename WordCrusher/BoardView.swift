//
//  BoardView.swift
//  WordCrusher
//
//  Created by George Madrid on 6/21/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Cocoa

// Some mathematical constants that we will use over and over.
fileprivate let pi: CGFloat = 3.14159265359
fileprivate let rad3 = sqrt(3.0) as CGFloat
fileprivate let rad3Over2 = sqrt(3.0) / 2.0 as CGFloat
fileprivate let piOver3 = pi / 3.0

// Some display constants
fileprivate let gridLineWidth = 2.0 as CGFloat

// The vertices of a hexagon centered at the origin with unit side-length.
fileprivate let corners =
  [ 0, piOver3, 2 * piOver3, 3 * piOver3, 4 * piOver3, 5 * piOver3 ].map { rad in
    return ( CGPoint(x: cos(rad), y: sin(rad)) )
}

// Returns coordinates of the six corners of a hexagon with the supplied center and radius.
private func hexPoints(at center: CGPoint, radius: CGFloat) -> [CGPoint] {
  return corners.map { pt in
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

class BoardView: NSView {
  // The radius of all of the hexes in the grid
  // (The radius of a hex is the distance from the center to a vertex.
  //  It is also the radius of a circle through all of the vertices.
  //  It is also the side length of the hexagon.)
  var radius: CGFloat = 15.0 {
    didSet {
      recomputeDisplayElements()
      setNeedsDisplay(self.bounds)
    }
  }
  
  var inset: EdgeInsets = NSEdgeInsetsMake(5.0, 5.0, 5.0, 5.0) {
    didSet {
      setNeedsDisplay(self.bounds)
    }
  }
  
  var board: Board? {
    didSet {
      recomputeDisplayElements()
      setNeedsDisplay(self.bounds)
    }
  }
  
  var activeCell: CellIndex? {
    didSet {
      setNeedsDisplay(self.bounds)
    }
  }
  
  // A map from the cell index to the points. Used for rendering and hit-testing.
  private var centers: [CellIndex : CGPoint] = [:]
  
  private func recomputeDisplayElements() {
    centers.removeAll()
    
    guard let board = board else { return }
    
    // Compute the center of every cell in the current board.
    board.forEach { cellIndex in
      // Fun trig to find the center of a given hex grid cell.
      // x is easy, but has to account for the fact that cells overlap slightly.
      // y needs to account for the staggering from column to column.
      let x = inset.left + radius + 1.5 * CGFloat(cellIndex.col) * radius
      let y = inset.top + CGFloat(cellIndex.row + 1) * rad3 * radius
        + CGFloat(cellIndex.col % 2) * -rad3Over2 * radius
      centers[cellIndex as CellIndex] = CGPoint(x: x, y: y)
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    guard let context = NSGraphicsContext.current()?.cgContext else {
      return
    }
    
    // Move the origin to upper-left.
//    context.scaleBy(x: 1.0, y: -1.0)
//    context.translateBy(x: 0, y: -self.bounds.size.height)
    
    let bgcolor = NSColor(calibratedRed: 0.45, green: 0.45, blue: 1.0, alpha: 1.0).cgColor
    context.setFillColor(bgcolor)
    context.fill(bounds)

    guard let board = board else { return }
    
    context.setLineWidth(gridLineWidth)
    centers.forEach { (cellIndex: CellIndex, center: CGPoint) in
      let path = pathForPoly(points: hexPoints(at: center, radius: radius))
      context.addPath(path)
      
      context.setFillColor(NSColor.blue.cgColor)
      if let active = activeCell, cellIndex == active {
        context.setFillColor(NSColor.white.cgColor)
      }
      context.fillPath()
      
      context.addPath(path)
      context.strokePath()
      
      let letter = String(board[cellIndex])
      if letter != "." {
        let aStr = CFAttributedStringCreate(kCFAllocatorDefault, letter as CFString, [:] as CFDictionary)
        let aLine = CTLineCreateWithAttributedString(aStr!)
        context.textPosition = center
        CTLineDraw(aLine, context)
      }
    }
  }
}
