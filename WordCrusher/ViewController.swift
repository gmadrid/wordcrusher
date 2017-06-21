//
//  ViewController.swift
//  WordCrusher
//
//  Created by George Madrid on 6/20/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Cocoa
import StreamReader

class ViewController: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
//    let wordsStream = StreamReader(path: "/usr/share/dict/words")
//    let trie = Trie()
//    while let line = wordsStream?.nextLine() {
//      trie.insert(word: line)
//    }
    
  }

  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
}
