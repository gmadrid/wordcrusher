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
  
  private func adjacentString(to index: Board.CellIndex) throws -> String {
    let adjacent =
      try board.adjacent(to: index)
        .map { try board.lookup(index: $0) }
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
    board = try Board(rows: 2, cols: 4, contents: "QHELZXWY")
    
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
    board = try Board(rows: 3, cols: 4, contents: "HXOVBELLUQRY")
    
    let list = board.searchAll(in: trie)
    XCTAssertEqual([ "bell", "belly", "hell", "hello" ], list.sorted())
    
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
    board = try Board(rows: 3, cols: 4, contents: "KITTEHSHLLOY")
    
    // Test that it finds all versions of word and that it will find a word that continues another.
    let list = board.search(from: (1, 1), in: trie)
    XCTAssertEqual(["hell", "hell", "hello"], list.sorted())

    // Test that it will stop when nothing matches.
    let list2 = board.search(from: (1, 3), in: trie)
    XCTAssertEqual([], list2)
    
    // Test that it will stop when a word almost matches.
    let list3 = board.search(from: (0, 0), in: trie)
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
    board = try Board(rows: 3, cols: 4, contents: "KITTOHEYLLHX")
    
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
