//
//  Board.swift
//  WordCrusher
//
//  Created by George Madrid on 6/20/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation

/**
 * The WordCrusher board is defined as a RxC hexagonal grid.
 * - Rows ars staggered
 * - Columns are straight
 *
 * So, a 3x4 board:
 *
 *        1   3
 *      0   2
 *        1   3
 *      0   2
 *        1   3
 *      0   2
 *
 * Each row starts counting columns at zero, and the columns are staggered
 * up and down.
 *
 * Since the grid is hexagonal, each cell has potentially 6 neighbors.
 * For example, the neighbors of (1, 2) are (0, 2), (2, 2), (1, 1), (1, 3), (2, 1), (2, 3).
 *
 * TODO: deal with limiting the ch values in the cells to a...z and '.'
 */
class Board {
  let numRows: Int
  let numCols: Int

  var numCells: Int { return numRows * numCols }

  fileprivate var cells: [CellContents]

  init(rows: Int, cols: Int, contents contents_: String? = nil) {
    numRows = rows
    numCols = cols

    var contents = contents_ ?? ""

    let numCells = rows * cols
    if contents.characters.count < numCells {
      contents += String(repeating: ".", count: numCells - contents.characters.count)
    }

    cells = zip(0 ..< numCells, contents.lowercased().characters)
      .map { _, ch in
        if "a" ... "z" ~= ch {
          return .letter(ch: ch)
        } else {
          return .empty
        }
      }
  }

  fileprivate func arrayIndex(for cellIndex: CellIndex) -> Int {
    assert(isIndexInBoard(index: cellIndex))
    return cellIndex.row * numCols + cellIndex.col
  }

  fileprivate func isIndexInBoard(index: CellIndex) -> Bool {
    return 0 ..< numRows ~= index.row && 0 ..< numCols ~= index.col
  }

  // This is not bounds checked.
  fileprivate func arrayIndex(at cellIndex: CellIndex) -> Int {
    return cellIndex.row * numCols + cellIndex.col
  }

  func setChar(at cellIndex: CellIndex, ch: Character) {
    // TODO: handle spaces.
    // TODO: handle case conversion?
    // TODO: check range of ch.
    guard isIndexInBoard(index: cellIndex) else {
      fatalError("\(cellIndex) is out of range \(numRows)x\(numCols)")
    }
    let i = arrayIndex(at: cellIndex)
    cells[i] = .letter(ch: ch)
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
    var visitedSet = Set<CellIndex>()
    searchHelper(start, trie.search(), "", currentDepth: 0, maxDepth: maxDepth, visited: &visitedSet, cb: cb)
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
                                maxDepth: UInt,
                                visited: inout Set<CellIndex>,
                                cb: (String) -> Void) {
    // Upon entry:
    // - Token does NOT include the letter in this cell
    // - The cell has NOT been marked

    // If we've already used this cell, it cannot be used again.
    if visited.contains(index) { return }

    visited.insert(index)
    defer { visited.remove(index) }

    let thisIndex = arrayIndex(for: index)

    // Only match when the cell contains letters.
    guard case let CellContents.letter(thisLetter) = cells[thisIndex] else { return }

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
        searchHelper(nextCell, thisToken, newSoFar, currentDepth: currentDepth + 1, maxDepth: maxDepth, visited: &visited, cb: cb)
      }
    }
  }

  func adjacent(to index: CellIndex) -> [CellIndex] {
    let offsets: [CellIndex]
    if index.col % 2 == 0 {
      offsets = [(-1, 0), (1, 0), (0, 1), (1, 1), (0, -1), (1, -1)].map { row, col in
        CellIndex(row: row, col: col)
      }
    } else {
      offsets = [(1, 0), (-1, 0), (-1, 1), (0, 1), (0, -1), (-1, -1)].map { row, col in
        CellIndex(row: row, col: col)
      }
    }

    return offsets.map { offsetindex in
      CellIndex(row: index.row + offsetindex.row, col: index.col + offsetindex.col)
    }
    .filter { index in
      self.isIndexInBoard(index: index)
    }
  }
  
  func collapse(at cellIndex: CellIndex) {
    var index = arrayIndex(for: cellIndex)
    while index >= numCols {
      cells[index] = cells[index - numCols]
      index -= numCols
    }
    cells[index] = .empty
  }
}

extension Board {
  subscript(cellIndex: CellIndex) -> Character? {
    assert(isIndexInBoard(index: cellIndex), "[\(cellIndex.row), \(cellIndex.col)] is out of range: [\(numRows), \(numCols)]")
    if case let CellContents.letter(ch) = cells[cellIndex.row * numCols + cellIndex.col] {
      return ch
    }
    return nil
  }

  subscript(row: Int, col: Int) -> Character? {
    let index = CellIndex(row: row, col: col)
    return self[index]
  }
}

extension Board: Sequence {
  class BoardIterator: IteratorProtocol {
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

  func nextCell(cellIndex: CellIndex) -> CellIndex {
    var row = cellIndex.row
    var col = cellIndex.col + 1
    if col >= numCols {
      col = 0
      row += 1
    }
    if row >= numRows {
      row = 0
      col = 0
    }
    return CellIndex(row: row, col: col)
  }

  func makeIterator() -> BoardIterator {
    return BoardIterator(maxRow: numRows, maxCol: numCols)
  }
}

fileprivate enum CellContents {
  case empty
  case letter(ch: Character)
}

public struct CellIndex {
  static let zero = CellIndex(row: 0, col: 0)

  let row: Int
  let col: Int

  init(row: Int, col: Int) {
    self.row = row
    self.col = col
  }
}

extension CellIndex: Equatable {
  public static func ==(lhs: CellIndex, rhs: CellIndex) -> Bool {
    return lhs.row == rhs.row && lhs.col == rhs.col
  }
}

extension CellIndex: Hashable {
  public var hashValue: Int { return row.hashValue ^ col.hashValue }
}
