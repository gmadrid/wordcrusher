//
//  BoardView.swift
//  WordCrusher
//
//  Created by George Madrid on 6/21/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Cocoa

// Some mathematical constants that we will use over and over.
private let pi: CGFloat = 3.14159265359
private let rad3 = sqrt(3.0) as CGFloat
private let rad3Over2 = sqrt(3.0) / 2.0 as CGFloat
private let piOver3 = pi / 3.0

// Some display constants
private let gridLineWidth = 2.0 as CGFloat

// The vertices of a hexagon centered at the origin with unit side-length.
private let corners =
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

protocol BoardViewDelegate {
  func activeCellChanged(to cell: CellIndex?)
}

class BoardView: NSView {
  var delegate: BoardViewDelegate?
  
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
      guard oldValue != activeCell else { return }
      setNeedsDisplay(self.bounds)
      if let d = delegate {
        d.activeCellChanged(to: activeCell)
      }
    }
  }
  
  var hoverCell: CellIndex? {
    didSet {
      guard oldValue != hoverCell else { return }
      setNeedsDisplay(self.bounds)
    }
  }
  
  // A map from the cell index to the points. Used for rendering and hit-testing.
  fileprivate var centers: [CellIndex : CGPoint] = [:]
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    
    let trackingArea = NSTrackingArea(rect: bounds,
                                      options: [
                                        .mouseMoved,
                                        .mouseEnteredAndExited,
                                        .activeAlways,
                                        .inVisibleRect],
                                      owner: self,
                                      userInfo: nil)
    addTrackingArea(trackingArea)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
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
      let invertedY = bounds.height - y
      centers[cellIndex as CellIndex] = CGPoint(x: x, y: invertedY)
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    guard let context = NSGraphicsContext.current()?.cgContext else {
      return
    }
    
    let bgcolor = NSColor(calibratedRed: 0.45, green: 0.45, blue: 1.0, alpha: 1.0).cgColor
    context.setFillColor(bgcolor)
    context.fill(bounds)

    guard let board = board else { return }
    
    let textFont = NSFont.boldSystemFont(ofSize: radius/1.5)
    centers.forEach { (cellIndex: CellIndex, center: CGPoint) in
      let path = pathForPoly(points: hexPoints(at: center, radius: radius))
      context.addPath(path)
      
      context.setFillColor(NSColor.blue.cgColor)
      if let active = activeCell, cellIndex == active {
        context.setFillColor(NSColor.white.cgColor)
      }
      context.fillPath()
      
      context.addPath(path)
      context.setLineWidth(gridLineWidth)
      context.strokePath()
      
      if let hover = hoverCell, cellIndex == hover {
        let hoverPath = pathForPoly(points: hexPoints(at: center, radius: radius - 5))
        context.setLineWidth(1)
        context.addPath(hoverPath)
        context.strokePath()
      }

      let letter = String(board[cellIndex])
      if letter != "." {
        let aStr = NSAttributedString(string: letter, attributes: [NSFontAttributeName:textFont])
        let aLine = CTLineCreateWithAttributedString(aStr)
        let aLineBounds = CTLineGetBoundsWithOptions(aLine, [])
        context.textPosition = CGPoint(x: center.x - aLineBounds.width / 2, y: center.y - aLineBounds.height / 2)
        CTLineDraw(aLine, context)
      }
    }
  }
}

extension BoardView {
  private func closestCell(to point: CGPoint) -> CellIndex? {
    let closest = centers.min { e1, e2 -> Bool in
      let d1 = Util.distanceSquared(p1: e1.value, p2: point)
      let d2 = Util.distanceSquared(p1: e2.value, p2: point)
      return d1 < d2
    }
    return closest?.key
  }
  
  private func cellContainingPoint(_ point: CGPoint) -> CellIndex? {
    let closestCell_ = closestCell(to: point)
    guard let closestCell = closestCell_ else { return nil }
    
    let closestPt_ = centers[closestCell]
    guard let closestPt = closestPt_ else {
      // This should never happen
      return nil
    }
    
    // Make sure that the point is actually *inside* the closest cell
    let dist = Util.distanceSquared(p1: closestPt, p2: point)
    guard dist < radius * radius else { return nil }
    
    return closestCell
  }
  
  override func mouseMoved(with event: NSEvent) {
    hoverCell = cellContainingPoint(event.locationInWindow)
  }
  
  override func mouseDown(with event: NSEvent) {
    activeCell = cellContainingPoint(event.locationInWindow)
  }
}


