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
  var boardView: BoardView!
  var boardViewModel: BoardViewModel!
  
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let board = Board(rows: 5, cols: 6, contents: "abcdefghijklmnopqrstuvwxyz")
    boardViewModel = BoardViewModel(board: board)
    boardView = BoardView(frame: view.bounds)
    boardView.radius = 22
    boardView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
    view.addSubview(boardView)
    boardView.board = board
    
    let button = NSButton(title: "A button", target: self, action: #selector(buttonTapped(_:)))
    view.addSubview(button)

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
        
        let myboard = Board(rows: 5, cols: 6, contents: "rrahrbysheruprrelaottboereyckt")
        myboard.searchAll(in: trie) { word in
//          if word.characters.count > 7 { Swift.print(word) }
        }
        
        return trie
      }
      .shareReplay(1)
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .asDriver(onErrorJustReturn: Trie())
      .drive(onNext: { trie in })

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
  
  func buttonTapped(_ sender: Any?) {
//    boardViewModel.activeCell_.value = CellIndex(row: 5, col: 5)
    if boardView.activeCell == nil {
      boardView.activeCell = CellIndex(row: 2, col: 3)
    } else {
      boardView.activeCell = CellIndex(row: 3, col: 0)
    }
  }

  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
}
