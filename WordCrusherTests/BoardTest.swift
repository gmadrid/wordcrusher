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
    XCTAssertEqual("AFIJ", try adjacentString(to: (1, 0)))
    XCTAssertEqual("CFHJKL", try adjacentString(to: (1, 2)))
    XCTAssertEqual("BEF", try adjacentString(to: (0, 0)))
    XCTAssertEqual("EJ", try adjacentString(to: (2, 0)))
    XCTAssertEqual("GJL", try adjacentString(to: (2, 2)))
    
    // Try some odd columns
    XCTAssertEqual("ACF", try adjacentString(to: (0, 1)))
    XCTAssertEqual("CH", try adjacentString(to: (0, 3)))
    XCTAssertEqual("ABCEGJ", try adjacentString(to: (1, 1)))
    XCTAssertEqual("GHK", try adjacentString(to: (2, 3)))
  }
  
}
