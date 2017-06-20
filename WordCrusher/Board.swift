//
//  Board.swift
//  WordCrusher
//
//  Created by George Madrid on 6/20/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation

enum Errs : Error {
  case contentsIsWrongLength
  case indexOutOfRange
}

/**
  The WordCrusher board is defined as a RxC hexagonal grid.
  - Rows ars staggered
  - Columns are straight
 
  So, a 3x4 board:
 
        1   3
      0   2
        1   3
      0   2
        1   3
      0   2
 
   Each row starts counting columns at zero, and the columns are staggered
   up and down.
 
   Since the grid is hexagonal, each cell has potentially 6 neighbors. 
   For example, the neighbors of (1, 2) are (0, 2), (2, 2), (1, 1), (1, 3), (2, 1), (2, 3).
 */
class Board {
  typealias CellIndex = (Int, Int)

  private struct Cell {
    let letter: Character
    var mark: Bool = false
    
    init(letter: Character) {
      self.letter = letter
    }
  }
  
  let numRows: Int
  let numCols: Int
  private let cells: [Cell]
  
  init(rows: Int, cols: Int, contents: String) throws {
    self.numRows = rows
    self.numCols = cols
    let chars = contents.characters
    
    guard chars.count == rows * cols else {
      throw Errs.contentsIsWrongLength
    }
    var chs = Array<Cell>()
    for ch in chars {
      chs.append(Cell(letter: ch))
    }
    self.cells = chs
  }
  
  fileprivate func indexInBoard(index: CellIndex) -> Bool {
    let (row, col) = index
    return 0..<numRows ~= row && 0..<numCols ~= col
  }

  func adjacent(index: CellIndex) -> [CellIndex] {
    let (row, col) = index
    let offsets: [CellIndex]
    if col % 2 == 0 {
      offsets = [(-1, 0), (1, 0), (0, 1), (1, 1), (0, -1), (1, -1)]
    } else {
      offsets = [(1, 0), (-1, 0), (-1, 1), (0, 1), (0, -1), (-1, -1)]
    }
    
    return offsets.map { (offsetrow, offsetcol) in
      return (row + offsetrow, col + offsetcol)
      }
      .filter { self.indexInBoard(index: $0)
    }
  }
  
  func lookup(index: CellIndex) throws -> Character {
    let (row, col) = index
    let arrayIndex = row * numCols + col
    guard 0..<cells.count ~= arrayIndex else {
      throw Errs.indexOutOfRange
    }
    return cells[arrayIndex].letter
  }
}
