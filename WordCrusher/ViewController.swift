//
//  ViewController.swift
//  WordCrusher
//
//  Created by George Madrid on 6/20/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Cocoa
import RxCocoa
import RxSwift
import StreamReader

class ViewController: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    
    let boardView = BoardView(frame: view.bounds, rows: 3, cols: 7, sideLength: 15.0)
    boardView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
    view.addSubview(boardView)
    
    _ = Observable.just("/usr/share/dict/words")
      .map { path -> Trie in
        let trie = Trie()
        let wordStream = StreamReader(path: path)
        // TODO error
        while let line = wordStream?.nextLine() {
          // No dictionary words shorter than 3.
          if line.characters.count > 2 {
            trie.insert(word: line)
          }
        }
        return trie
      }
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .asDriver(onErrorJustReturn: Trie())
      .drive(onNext: { trie in print(trie) },
             onCompleted: { print ("COMPLETE") })

    //    print("Loading dict")
    //    let wordsStream = StreamReader(path: "/usr/share/dict/words")
    //    let trie = Trie()
    //    while let line = wordsStream?.nextLine() {
    //      // No dictionary words shorter than 3.
    //      if line.characters.count > 2 {
    //        trie.insert(word: line)
    //      }
    //    }
    //    print("Done loading dict")
    //
    //    let startBoard = "essayrtmaxnovelagilcisedchtory"
    //    let afterEssayNovel = "rtmaxagilcisedyhtory.........."
    //    let afterClimax = "rtedyagoryis...ht............."
    //    let afterTragedy = "isoryht......................."
    //    let board = try! Board(rows: 6, cols: 5, contents: afterTragedy)
    //    board.searchAll(in: trie) { word in
    //      print(word)
    //    }
  }

  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
}
