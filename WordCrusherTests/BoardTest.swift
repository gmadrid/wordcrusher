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
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func adjacentString(board: Board, index: Board.CellIndex) throws -> String {
    let adjacent =
      try board.adjacent(index: index)
        .map { try board.lookup(index: $0) }
        .sorted()
    return String(adjacent)
  }
  
  func testBoard() throws {
    // The board looks like this:
    //
    //    B   D
    //  A   C
    //    F   H
    //  E   G
    //    J   L
    //  I   K
    let board = try Board(rows: 3, cols: 4, contents: "ABCDEFGHIJKL")

    // This little exercise tests both adjacent and lookup.
    
    // Try some even columns
    XCTAssertEqual("AFIJ", try adjacentString(board: board, index: (1, 0)))
    XCTAssertEqual("CFHJKL", try adjacentString(board: board, index: (1, 2)))
    XCTAssertEqual("BEF", try adjacentString(board: board, index: (0, 0)))
    XCTAssertEqual("EJ", try adjacentString(board: board, index: (2, 0)))
    XCTAssertEqual("GJL", try adjacentString(board: board, index: (2, 2)))
    
    // Try some odd columns
    XCTAssertEqual("ACF", try adjacentString(board: board, index: (0, 1)))
    XCTAssertEqual("CH", try adjacentString(board: board, index: (0, 3)))
    XCTAssertEqual("ABCEGJ", try adjacentString(board: board, index: (1, 1)))
    XCTAssertEqual("GHK", try adjacentString(board: board, index: (2, 3)))
  }
  
}
