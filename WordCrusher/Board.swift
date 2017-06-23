//
//  Board.swift
//  WordCrusher
//
//  Created by George Madrid on 6/20/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation

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
  typealias CellIndex = CellIndex_

  private struct Cell {
    let letter: Character
    var visited: Bool = false

    init(letter: Character) {
      self.letter = letter
    }
  }

  let numRows: Int
  let numCols: Int
  private var cells: [Cell]
  
  var numCells: Int { return numRows * numCols }

  init(rows: Int, cols: Int, contents: String? = nil) {
    numRows = rows
    numCols = cols
    
    var correctedString = contents ?? ""
    
    let numCells = rows * cols
    if correctedString.characters.count < numCells {
      correctedString += String(repeating: ".", count: numCells - correctedString.characters.count)
    }
    
    cells = zip(0..<numCells, correctedString.lowercased().characters)
      .map { (i, ch) in
        return Cell(letter: ch)
    }
  }
  
  subscript(row: Int, col: Int) -> Character {
    let index = CellIndex(row: row, col: col)
    assert(isIndexInBoard(index: index), "[\(row), \(col)] is out of range: [\(numRows), \(numCols)]")
    let arrayIndex = row * numCols + col
    return cells[arrayIndex].letter
  }

  fileprivate func isIndexInBoard(index: CellIndex) -> Bool {
    return 0 ..< numRows ~= index.row && 0 ..< numCols ~= index.col
  }

  func searchAll(in trie: Trie, maxDepth: UInt = UInt.max, cb: (String) -> Void) {
    for row in 0 ..< numRows {
      for col in 0 ..< numCols {
        let index = CellIndex(row: row, col: col)
        search(from: index, in: trie, maxDepth: maxDepth, cb: cb)
      }
    }
  }

  func searchAll(in trie: Trie, maxDepth: UInt = UInt.max) -> [String] {
    var response: [String] = []
    searchAll(in: trie, maxDepth: maxDepth) { response.append($0) }
    return response
  }

  func search(from start: CellIndex, in trie: Trie, maxDepth: UInt = UInt.max, cb: (String) -> Void) {
    searchHelper(start, trie.search(), "", currentDepth: 0, maxDepth: maxDepth, cb: cb)
  }

  func search(from start: CellIndex, in trie: Trie, maxDepth: UInt = UInt.max) -> [String] {
    var response: [String] = []
    _ = search(from: start, in: trie, maxDepth: maxDepth) {
      response.append($0)
    }
    return response
  }

  // If cb returns true, then stop right away.
  // Returns true if the search should stop right away.
  // TODO: fix the BUG. This doesn't work with maxDepth = 0
  fileprivate func searchHelper(_ index: CellIndex, _ token: TrieToken, _ soFar: String,
                                currentDepth: UInt,
                                maxDepth: UInt, cb: (String) -> Void) {
    // Upon entry:
    // - Token does NOT include the letter in this cell
    // - The cell has NOT been marked
    let thisIndex = index.row * numCols + index.col

    // If we've already used this cell, it cannot be used again.
    if cells[thisIndex].visited {
      return
    }

    cells[thisIndex].visited = true
    defer { cells[thisIndex].visited = false }

    let thisLetter = cells[thisIndex].letter
    guard let thisToken = token.next(thisLetter) else {
      // This letter does not advance the search, so leave but continue searching.
      return
    }
    var newSoFar = soFar
    newSoFar.append(thisLetter)
    if thisToken.isWord {
      cb(newSoFar)
    }

    if currentDepth < maxDepth - 1 {
      for nextCell in adjacent(to: index) {
        searchHelper(nextCell, thisToken, newSoFar, currentDepth: currentDepth + 1, maxDepth: maxDepth, cb: cb)
      }
    }
  }

  func adjacent(to index: CellIndex) -> [CellIndex] {
    let offsets: [CellIndex]
    if index.col % 2 == 0 {
      offsets = [(-1, 0), (1, 0), (0, 1), (1, 1), (0, -1), (1, -1)].map { (row, col) in
        return CellIndex(row: row, col: col)
      }
    } else {
      offsets = [(1, 0), (-1, 0), (-1, 1), (0, 1), (0, -1), (-1, -1)].map { (row, col) in
        return CellIndex(row: row, col: col)
      }
    }

    return offsets.map { offsetindex in
      CellIndex(row: index.row + offsetindex.row, col: index.col + offsetindex.col)
      }
      .filter { index in
        self.isIndexInBoard(index: index)
    }
  }

  func lookup(index: CellIndex) throws -> Character {
    let arrayIndex = index.row * numCols + index.col
    guard 0 ..< cells.count ~= arrayIndex else {
      throw Errs.indexOutOfRange
    }
    return cells[arrayIndex].letter
  }
}

extension Board : Sequence {
  class BoardIterator : IteratorProtocol {
    typealias Element = CellIndex
    
    // Current values are what we will return from the next() call.
    private var currRow = 0
    private var currCol = 0
    
    private let maxRow: Int
    private let maxCol: Int
    
    init(maxRow: Int, maxCol: Int) {
      self.maxRow = maxRow
      self.maxCol = maxCol
    }
    
    func next() -> CellIndex? {
      if currRow >= maxRow {
        return nil
      }
      
      let result = CellIndex(row: currRow, col: currCol)
      
      currCol += 1
      if currCol >= maxCol {
        currCol = 0
        currRow = currRow + 1
      }
      return result
    }
  }
  
  func makeIterator() -> BoardIterator {
    return BoardIterator(maxRow: numRows, maxCol: numCols)
  }
}

class CellIndex_ : Equatable, Hashable {
  public var hashValue: Int { return row.hashValue ^ col.hashValue }
  
  static let zero = CellIndex_(row: 0, col: 0)
  
  let row: Int
  let col: Int
  init(row: Int, col: Int) {
    self.row = row
    self.col = col
  }
  
  public static func ==(lhs: CellIndex_, rhs: CellIndex_) -> Bool {
    return lhs.row == rhs.row && lhs.col == rhs.col
  }
}
