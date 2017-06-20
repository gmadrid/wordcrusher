//
//  Trie.swift
//  WordCrusher
//
//  Created by George Madrid on 6/20/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation

/**
 - Read from file (one word per line)
   (Plurals?)
 - insert word
 - Query letter by letter.
 - Query by prefix
 */

fileprivate class TrieNode {
  let letter: Character
  lazy var children: [Character:TrieNode] = [Character:TrieNode]()
  var isWord: Bool = false
  
  init(letter: Character) {
    self.letter = letter
  }
  
  func getChildNode(letter: Character) -> TrieNode? {
    return children[letter]
  }
  
  func getOrCreateChildNode(letter: Character) -> TrieNode {
    if let node = getChildNode(letter: letter) {
      return node
    }
    
    let newNode = TrieNode(letter: letter)
    children[letter] = newNode
    return newNode
  }
}

class TrieToken {
  fileprivate let node: TrieNode

  var isWord: Bool {
    return node.isWord
  }
  
  fileprivate init(node: TrieNode) {
    self.node = node
  }
  
  func next(_ letter: Character) -> TrieToken? {
    guard let nextNode = node.children[letter] else {
      return nil
    }
    return TrieToken(node: nextNode)
  }
}

class Trie {
  fileprivate var root = TrieNode(letter: Character(" "))

  func insert(word: String) {
    let node = word.characters.reduce(root) { (currentNode, ch) -> TrieNode in
      return currentNode.getOrCreateChildNode(letter:ch)
    }
    node.isWord = true
  }
  
  func contains(word: String) -> Bool {
    var currentNode: TrieNode? = root
    for ch in word.characters {
      switch currentNode?.getChildNode(letter: ch) {
      case .none:
        return false
      case .some(let node):
        currentNode = node
      }
    }
    return currentNode?.isWord ?? false
  }
  
  func search() -> TrieToken {
    return TrieToken(node: root)
  }
}
