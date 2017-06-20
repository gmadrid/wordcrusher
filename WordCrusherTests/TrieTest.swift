//
//  TrieTest.swift
//  WordCrusher
//
//  Created by George Madrid on 6/20/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import XCTest
@testable import WordCrusher

class TrieTest: XCTestCase {
  var trie: Trie!
  
  override func setUp() {
    super.setUp()

    trie = Trie()
    trie.insert(word: "dog")
    trie.insert(word: "car")
    trie.insert(word: "dogfood")
    trie.insert(word: "doggerel")
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testInsertionAndContains() {
    XCTAssert(trie.contains(word: "dog"))
    XCTAssert(trie.contains(word: "car"))
    XCTAssert(trie.contains(word: "dogfood"))
    XCTAssert(trie.contains(word: "doggerel"))
    
    XCTAssert(!trie.contains(word: "cat"))
    XCTAssert(!trie.contains(word: "do"))
    XCTAssert(!trie.contains(word: "dogg"))
    XCTAssert(!trie.contains(word: "dogxx"))
    XCTAssert(!trie.contains(word: "dof"))
    XCTAssert(!trie.contains(word: "dogfoodxx"))
    XCTAssert(!trie.contains(word: "doggerelxx"))
    
    trie.insert(word: "dogg")
    XCTAssert(trie.contains(word: "dogg"))
  }
  
  enum TestErr : Error {
    case UnexpectedNilTrieToken
  }
  
  func expectToken(_ token: TrieToken?) throws -> TrieToken {
    guard let token = token else {
      throw TestErr.UnexpectedNilTrieToken
    }
    return token
  }
  
  func testSearch() throws {
    let search : TrieToken = trie.search()
    
    // Test nothing at start of search.
    XCTAssertNil(search.next("a"))
    
    // Test successful searches both in middle and at end of word.
    var token = try expectToken(search.next("d"))
    XCTAssert(!token.isWord)
    token = try expectToken(token.next("o"))
    XCTAssert(!token.isWord)
    token = try expectToken(token.next("g"))
    XCTAssert(token.isWord)
    
    // Test bad search in middle.
    XCTAssertNil(token.next("x"))
    
    // Test successful searches continuing from end of word.
    token = try expectToken(token.next("f"))
    XCTAssert(!token.isWord)
    token = try expectToken(token.next("o"))
    XCTAssert(!token.isWord)
    token = try expectToken(token.next("o"))
    XCTAssert(!token.isWord)
    token = try expectToken(token.next("d"))
    XCTAssert(token.isWord)
    
    XCTAssertNil(token.next("f"))
  }
}
