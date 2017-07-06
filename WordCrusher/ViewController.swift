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
  
  var statusViewModel: StatusViewModel!
  
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

    boardViewModel = BoardViewModel(board: board,
                                    activeCell: boardView.rx.activeCell,
                                    charInput: boardView.rx.ch.asObservable())
    boardViewModel.boardChanged
      .subscribe(onNext: { [weak self] in
        self?.boardView.setNeedsDisplay(self?.boardView.bounds ?? CGRect.zero)
      })
      .disposed(by: disposeBag)
    
    
    let statusView = NSTextField(frame: CGRect.zero)
    statusView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(statusView)

    statusView.leftAnchor.constraint(equalTo: boardView.leftAnchor).isActive = true
    statusView.bottomAnchor.constraint(equalTo: boardView.bottomAnchor).isActive = true
    statusView.widthAnchor.constraint(equalTo: boardView.widthAnchor).isActive = true
    statusView.heightAnchor.constraint(equalToConstant: 20).isActive = true
    statusView.backgroundColor = NSColor.clear
    
    let messages = PublishSubject<Status>()
    statusViewModel = StatusViewModel(messages: messages.asObservable())
    statusViewModel.text.bind(to: statusView.rx.text).disposed(by: disposeBag)
    
    _ = Observable.just("/usr/share/dict/words")
      .map { path -> Trie in
        let trie = Trie()
        let wordStream = StreamReader(path: path)
        // TODO: error
        messages.onNext(.message("Reading trie..."))
        var lineNumber = 0
        while let line = wordStream?.nextLine() {
          // No dictionary words shorter than 3.
          if line.characters.count > 2 {
            trie.insert(word: line)
          }
          
          lineNumber += 1
          messages.onNext(.message("Reading trie...\(lineNumber)"))
        }
        messages.onNext(.message("Searching..."))

        let myboard = Board(rows: 6, cols: 6, contents: "............n.....in..ipacipcrteuome")
        Swift.print("WORDS")
        myboard.searchAll(in: trie) { word in
          if word.characters.count >= 6 { Swift.print(word) }
        }
        
        messages.onNext(.none)

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
