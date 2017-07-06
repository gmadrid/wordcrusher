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

  override var acceptsFirstResponder: Bool { Swift.print("AFR"); return true }

  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    let board = Board(rows: 5, cols: 6, contents: "abcdefghijklmnopqrstuvwxyz")

    boardView = BoardView(frame: view.bounds)
    boardView.radius = 22
    boardView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
    boardView.board = board
    view.addSubview(boardView)

    let charInput = Variable<Character>("a")

    boardViewModel = BoardViewModel(board: board,
                                    activeCell: boardView.rx.activeCell.asObservable(),
                                    charInput: charInput.asObservable())

    //    boardView.activeCell = CellIndex(row: 1, col: 1)
    charInput.value = "D"
    charInput.value = "F"

    let button = NSButton(title: "A button", target: self, action: #selector(buttonTapped(_:)))
    view.addSubview(button)

    _ = Observable.just("/usr/share/dict/words")
      .map { path -> Trie in
        let trie = Trie()
        let wordStream = StreamReader(path: path)
        // TODO: error
        while let line = wordStream?.nextLine() {
          // No dictionary words shorter than 3.
          if line.characters.count > 2 {
            trie.insert(word: line)
          }
        }

        //        let myboard = Board(rows: 5, cols: 6, contents: "..........a.....w..s..cr.urlao")
        //        myboard.searchAll(in: trie) { word in
        //                    if word.characters.count >= 4 { Swift.print(word) }
        //        }
        //
        return trie
      }
      .shareReplay(1)
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .asDriver(onErrorJustReturn: Trie())
      .drive(onNext: { _ in })

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

    print("FOOBAR")
    boardView.becomeFirstResponder()
    print("BAZ: \(NSApplication.shared().keyWindow)")
  }

  override func keyDown(with event: NSEvent) {
    Swift.print(event)
    super.keyDown(with: event)
  }

  func buttonTapped(_: Any?) {
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
