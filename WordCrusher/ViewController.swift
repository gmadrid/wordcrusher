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
  var boardViewModel: BoardViewModel!
  
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let board = try! Board(rows: 4, cols: 5)
    boardViewModel = BoardViewModel(board: board)
    let boardView = BoardView(frame: view.bounds, viewModel: boardViewModel)
    boardView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
    view.addSubview(boardView)
    
//    for foo in board {
//      print(foo)
//    }
    
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
          if word.characters.count > 7 { Swift.print(word) }
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
    boardViewModel.activeCell_.value = Board.CellIndex(row: 5, col: 5)
  }

  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
}
