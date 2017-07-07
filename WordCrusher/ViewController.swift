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

  var searchService: SearchService!
  var trieService: TrieService!
  var boardViewModel: BoardViewModel!
  var statusViewModel: StatusViewModel!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Start this as soon as possible.
    trieService = TrieService()
    
    let board = Board(rows: 6, cols: 6, contents: "............n.....in..ipacipcrteuome")
    let boardView = makeBoardView(board: board)
    view.addSubview(boardView)
    
    let statusView = makeStatusView()
    view.addSubview(statusView)
    
    constrainViews(boardView: boardView, statusView: statusView)
    
    let statusQueue = trieService.status
    boardViewModel = makeBoardViewModel(board: board, boardView: boardView)
    statusViewModel = makeStatusViewModel(statusQueue: statusQueue, statusView: statusView)
    searchService = SearchService(boardChanged: boardViewModel.boardChanged, trie: trieService.trie)

    boardViewModel.activeCell.onNext(CellIndex(row: 0, col: 0))
    boardView.becomeFirstResponder()
  }
  
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
