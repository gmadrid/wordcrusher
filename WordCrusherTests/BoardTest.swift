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
  
  func adjacentString(to index: Board.CellIndex) throws -> String {
    let adjacent =
      try board.adjacent(to: index)
        .map { try board.lookup(index: $0) }
        .sorted()
    return String(adjacent)
  }
  
  func testSearch() throws {
    let trie = Trie()
    trie.insert(word: "hello")
    trie.insert(word: "kitty")
    trie.insert(word: "hell")
    
    // The 3x4 board looks like this:
    //    
    //     I   T
    //   K   T
    //     H   H
    //   E   S
    //     L   Y
    //   L   O
    board = try Board(rows: 3, cols: 4, contents: "KITTEHSHLLOY")
    
    let list = board.search(from: (1, 1), in: trie)
    XCTAssertEqual(["hell", "hell", "hello"], list.sorted())
    let list2 = board.search(from: (1, 3), in: trie)
    XCTAssertEqual([], list2)
    let list3 = board.search(from: (0, 0), in: trie)
    XCTAssertEqual([], list3)
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
    board = try Board(rows: 3, cols: 4, contents: "ABCDEFGHIJKL")

    // This little exercise tests both adjacent and lookup.
    
    // Try some even columns
    XCTAssertEqual("afij", try adjacentString(to: (1, 0)))
    XCTAssertEqual("cfhjkl", try adjacentString(to: (1, 2)))
    XCTAssertEqual("bef", try adjacentString(to: (0, 0)))
    XCTAssertEqual("ej", try adjacentString(to: (2, 0)))
    XCTAssertEqual("gjl", try adjacentString(to: (2, 2)))
    
    // Try some odd columns
    XCTAssertEqual("acf", try adjacentString(to: (0, 1)))
    XCTAssertEqual("ch", try adjacentString(to: (0, 3)))
    XCTAssertEqual("abcegj", try adjacentString(to: (1, 1)))
    XCTAssertEqual("ghk", try adjacentString(to: (2, 3)))
  }
  
}
