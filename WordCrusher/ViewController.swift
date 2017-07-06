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
  let disposeBag = DisposeBag()

  var boardViewModel: BoardViewModel!
  var statusViewModel: StatusViewModel!

  private func makeBoardView(board: Board) -> BoardView {
    let boardView = BoardView()
    boardView.translatesAutoresizingMaskIntoConstraints = false
    boardView.radius = 22
    boardView.board = board
    return boardView
  }

  private func makeBoardViewModel(board: Board, boardView: BoardView) -> BoardViewModel {
    let boardViewModel = BoardViewModel(board: board,
                                        activeCell: boardView.rx.activeCell,
                                        charInput: boardView.rx.ch.asObservable())
    boardViewModel.boardChanged
      .subscribe(onNext: { [weak boardView] in
        guard let boardView = boardView else { return }
        boardView.setNeedsDisplay(boardView.bounds)
      })
      .disposed(by: disposeBag)

    return boardViewModel
  }

  private func makeStatusView() -> NSTextField {
    let statusView = NSTextField(frame: CGRect.zero)
    statusView.translatesAutoresizingMaskIntoConstraints = false
    statusView.backgroundColor = NSColor.clear
    return statusView
  }

  private func makeStatusViewModel(statusQueue: Observable<Status>, statusView: NSTextField) -> StatusViewModel {
    let statusViewModel = StatusViewModel(messages: statusQueue)
    statusViewModel.text.bind(to: statusView.rx.text).disposed(by: disposeBag)
    return statusViewModel
  }

  private func constrainViews(boardView: BoardView, statusView: NSTextField) {
    boardView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    boardView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    boardView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

    statusView.leftAnchor.constraint(equalTo: boardView.leftAnchor).isActive = true
    statusView.rightAnchor.constraint(equalTo: boardView.rightAnchor).isActive = true
    statusView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    boardView.bottomAnchor.constraint(equalTo: statusView.topAnchor).isActive = true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    //    let board = Board(rows: 5, cols: 6, contents: "abcdefghijklmnopqrstuvwxyz")
    let board = Board(rows: 6, cols: 6, contents: "............n.....in..ipacipcrteuome")
    let boardView = makeBoardView(board: board)
    view.addSubview(boardView)

    let statusView = makeStatusView()
    view.addSubview(statusView)

    constrainViews(boardView: boardView, statusView: statusView)

    let messages = PublishSubject<Status>()
    boardViewModel = makeBoardViewModel(board: board, boardView: boardView)
    statusViewModel = makeStatusViewModel(statusQueue: messages, statusView: statusView)

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

        Swift.print("WORDS")
        board.searchAll(in: trie) { word in
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

    boardView.becomeFirstResponder()
  }

  override func keyDown(with event: NSEvent) {
    Swift.print(event)
    super.keyDown(with: event)
  }

  func buttonTapped(_: Any?) {
  }

  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
}
