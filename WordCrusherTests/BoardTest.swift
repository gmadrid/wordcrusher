//
//  BoardTest.swift
//  WordCrusher
//
//  Created by George Madrid on 6/20/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import XCTest
@testable import WordCrusher

class BoardTest: XCTestCase {
  var board: Board!

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  private func adjacentString(to index: CellIndex) throws -> String {
    let adjacent =
      board.adjacent(to: index)
      .map { board[$0] ?? "." }
      .sorted()
    return String(adjacent)
  }

  private func trieWithWords(_ words: [String]) -> Trie {
    let trie = Trie()
    words.forEach { trie.insert(word: $0) }
    return trie
  }

  func testNoReuseCells() throws {
    let trie = trieWithWords(["hele", "zxwy"])

    // The 2 x 2 board looks like this:
    //
    //   H   L
    // Q   E
    //   X   Y
    // Z   W
    //
    board = Board(rows: 2, cols: 4, contents: "QHELZXWY")
    XCTAssertEqual(8, board.numCells)

    // "hele" cannot be found without reusing the 'e'.
    let list = board.searchAll(in: trie)
    XCTAssertEqual(["zxwy"], list.sorted())
  }

  func testSearchMaxDepth() throws {
    let trie = trieWithWords(["hello", "hell", "bell", "belly"])

    // The 3x4 board looks like this:
    //
    //   X   V
    // H   O
    //   E   L
    // B   L
    //   Q   Y
    // U   R
    //
    board = Board(rows: 3, cols: 4, contents: "HXOVBELLUQRY")
    XCTAssertEqual(12, board.numCells)

    let list = board.searchAll(in: trie)
    XCTAssertEqual(["bell", "belly", "hell", "hello"], list.sorted())

    let shortList: [String] = board.searchAll(in: trie, maxDepth: 4)
    XCTAssertEqual(2, shortList.count)
  }

  func testSearch() throws {
    let trie = trieWithWords(["hello", "kitty", "hell"])

    // The 3x4 board looks like this:
    //
    //     I   T
    //   K   T
    //     H   H
    //   E   S
    //     L   Y
    //   L   O
    //
    board = Board(rows: 3, cols: 4, contents: "KITTEHSHLLOY")
    XCTAssertEqual(12, board.numCells)

    // Test that it finds all versions of word and that it will find a word that continues another.
    let list = board.search(from: CellIndex(row: 1, col: 1), in: trie)
    XCTAssertEqual(["hell", "hell", "hello"], list.sorted())

    // Test that it will stop when nothing matches.
    let list2 = board.search(from: CellIndex(row: 1, col: 3), in: trie)
    XCTAssertEqual([], list2)

    // Test that it will stop when a word almost matches.
    let list3 = board.search(from: CellIndex(row: 0, col: 0), in: trie)
    XCTAssertEqual([], list3)
  }

  func testSearchAll() throws {
    let trie = trieWithWords(["hello", "kitty", "hell"])

    // The 3x4 board looks like this:
    //
    //     I   T
    //   K   T
    //     H   Y
    //   O   E
    //     L   X
    //   L   H
    //
    board = Board(rows: 3, cols: 4, contents: "KITTOHEYLLHX")
    XCTAssertEqual(12, board.numCells)

    let list = board.searchAll(in: trie)
    XCTAssertEqual(["hell", "hell", "hello", "hello", "kitty"], list.sorted())
  }

  func testBoard() throws {
    // The 3x4 board looks like this:
    //
    //    B   D
    //  A   C
    //    F   H
    //  E   G
    //    J   L
    //  I   K
    //
    board = Board(rows: 3, cols: 4, contents: "ABCDEFGHIJKL")
    XCTAssertEqual(12, board.numCells)

    XCTAssertEqual("a", board[0, 0])

    // This little exercise tests both adjacent and lookup.
    // Try some even columns
    XCTAssertEqual("afij", try adjacentString(to: CellIndex(row: 1, col: 0)))
    XCTAssertEqual("cfhjkl", try adjacentString(to: CellIndex(row: 1, col: 2)))
    XCTAssertEqual("bef", try adjacentString(to: CellIndex(row: 0, col: 0)))
    XCTAssertEqual("ej", try adjacentString(to: CellIndex(row: 2, col: 0)))
    XCTAssertEqual("gjl", try adjacentString(to: CellIndex(row: 2, col: 2)))

    // Try some odd columns
    XCTAssertEqual("acf", try adjacentString(to: CellIndex(row: 0, col: 1)))
    XCTAssertEqual("ch", try adjacentString(to: CellIndex(row: 0, col: 3)))
    XCTAssertEqual("abcegj", try adjacentString(to: CellIndex(row: 1, col: 1)))
    XCTAssertEqual("ghk", try adjacentString(to: CellIndex(row: 2, col: 3)))
  }

  func testNoBoardString() {
    board = Board(rows: 2, cols: 3)
    XCTAssertEqual(6, board.numCells)
    XCTAssertNil(board[0, 0])
    XCTAssertNil(board[0, 1])
    XCTAssertNil(board[0, 2])
    XCTAssertNil(board[1, 0])
    XCTAssertNil(board[1, 1])
    XCTAssertNil(board[1, 2])
  }

  func testShortBoard() {
    board = Board(rows: 2, cols: 3, contents: "ABC")
    XCTAssertEqual(6, board.numCells)

    XCTAssertEqual("a", board[0, 0])
    XCTAssertEqual("b", board[0, 1])
    XCTAssertEqual("c", board[0, 2])
    XCTAssertNil(board[1, 0])
    XCTAssertNil(board[1, 1])
    XCTAssertNil(board[1, 2])
  }

  func testLongBoard() {
    board = Board(rows: 2, cols: 3, contents: "ABCDEFXXXXX")
    XCTAssertEqual(6, board.numCells)

    XCTAssertEqual("a", board[0, 0])
    XCTAssertEqual("b", board[0, 1])
    XCTAssertEqual("c", board[0, 2])
    XCTAssertEqual("d", board[1, 0])
    XCTAssertEqual("e", board[1, 1])
    XCTAssertEqual("f", board[1, 2])
  }

  func testIterator() throws {
    let numRows = 4
    let numCols = 5
    board = Board(rows: numRows, cols: numCols)

    var set: Set<CellIndex> = Set()
    for index in board {
      set.insert(index)
    }

    var verificationSet: Set<CellIndex> = Set()
    for row in 0 ..< numRows {
      for col in 0 ..< numCols {
        let index = CellIndex(row: row, col: col)
        verificationSet.insert(index)
      }
    }

    XCTAssertEqual(set, verificationSet)
  }
}
