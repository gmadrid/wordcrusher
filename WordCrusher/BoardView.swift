//
//  BoardView.swift
//  WordCrusher
//
//  Created by George Madrid on 6/21/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Cocoa
import RxCocoa
import RxSwift

fileprivate let pi: CGFloat = 3.14159265359
fileprivate let rad3 = sqrt(3.0) as CGFloat
fileprivate let rad3Over2 = sqrt(3.0) / 2.0 as CGFloat
fileprivate let piOver3 = pi / 3.0

// The vertices of a hexagon centered at the origin with unit side-length.
fileprivate let corners =
  [ 0, piOver3, 2 * piOver3, 3 * piOver3, 4 * piOver3, 5 * piOver3 ].map { rad in
    return ( CGPoint(x: cos(rad), y: sin(rad)) )
}

class BoardView: NSView {
  let disposeBag = DisposeBag()

  // (row, col)
  var dimensions: Variable<(Int, Int)> = Variable((0, 0) as (Int, Int))
  
  // The radius of all of the hexes in the grid
  // (The radius of a hex is the distance from the center to a vertex.
  //  It is also the radius of a circle through all of the vertices.
  //  It is also the side length of the hexagon.)
  let radius: CGFloat
  
  var inset: EdgeInsets = NSEdgeInsetsMake(5.0, 5.0, 5.0, 5.0) {
    didSet {
      setNeedsDisplay(self.bounds)
    }
  }
  
  init(frame frameRect: NSRect, viewModel: BoardViewModel) {
    self.radius = 20.0
    
    super.init(frame: frameRect)
    
    // If the board changes, load the new dimensions.
    viewModel.board_
      .map { board -> (Int, Int) in return (board.numRows, board.numCols) }
      .asDriver(onErrorJustReturn: (0,0))
      .drive(dimensions)
      .disposed(by: disposeBag)
    
    // If the dimensions change, redraw.
    dimensions
      .asObservable()
      .asDriver(onErrorJustReturn: (0, 0))
      .drive(onNext: { [weak self] (numRows, numCols) in
        guard let view = self else { return }
        view.setNeedsDisplay(view.bounds)
      })
      .disposed(by: disposeBag)
    
    // If the activeCell changes, redraw.
    viewModel.activeCell_
      .asDriver(onErrorJustReturn: Board.CellIndex.zero)
      .drive(onNext: { [weak self] _ in
        guard let view = self else { return }
        Swift.print("active cell changed")
        view.setNeedsDisplay(view.bounds)
      })
      .disposed(by: disposeBag)
    
    viewModel.changedCell_
      .startWith(Board.CellIndex.zero)
      .asDriver(onErrorJustReturn: Board.CellIndex.zero)
      .drive(onNext: { [weak self] _ in
        guard let view = self else { return }
        view.setNeedsDisplay(view.bounds)        
      })
      .disposed(by: disposeBag)
  }
  
  required init?(coder: NSCoder) {
    self.dimensions.value = (5, 5)
    self.radius = 20.0
    super.init(coder: coder)
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
    Swift.print("DRAWING")
    super.draw(dirtyRect)
    
    guard let context = NSGraphicsContext.current()?.cgContext else {
      return
    }
    
    // Move the origin to upper-left.
    context.scaleBy(x: 1.0, y: -1.0)
    context.translateBy(x: 0, y: -self.bounds.size.height)
    
    let firstHexCenter = CGPoint(x: inset.left + radius, y: inset.top + rad3 * radius)
    let firstRowCenters = centersForRow(at: firstHexCenter, cols: dimensions.value.1)
    let allCenters = copyRowCenters(firstRowCenters, count: dimensions.value.0)
    let hexPaths = allCenters.map { pathForPoly(points: hexPoints(at: $0, radius: radius)) }

    hexPaths.forEach { path in
      context.addPath(path)
      context.strokePath()
    }
  }
}
