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

let boardRows = 6
let boardCols = 6
let boardContents = "............n.....in..ipacipcrteuome"
let minWordLength = 5

class ViewController: NSViewController {
  let disposeBag = DisposeBag()

  var searchService: SearchService!
  var trieService: TrieService!
  var boardViewModel: BoardViewModel!
  var statusViewModel: StatusViewModel!
  let wordLength = BehaviorSubject<Int>(value: 5)
  let status = PublishSubject<Status>()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Start this as soon as possible.
    trieService = TrieService()

    let board = Board(rows: boardRows, cols: boardCols, contents: boardContents)
    let boardView = makeBoardView(board: board)
    view.addSubview(boardView)
    
    let wordLengthControl = makeWordLengthControl()
    view.addSubview(wordLengthControl)

    let statusView = makeStatusView()
    view.addSubview(statusView)

    constrainViews(boardView: boardView,
                   statusView: statusView,
                   wordLengthControl: wordLengthControl)
    
    let statusQueue = Observable.merge(trieService.status, status)
    boardViewModel = makeBoardViewModel(board: board, boardView: boardView)
    statusViewModel = makeStatusViewModel(statusQueue: statusQueue, statusView: statusView)
    searchService = SearchService(board: board,
                                  boardChanged: boardViewModel.boardChanged,
                                  trie: trieService.trie,
                                  wordLength: wordLength.asObservable())

    searchService.words
      .map {
        // Remove dups by making a set first, then sort.
        return Array(Set($0.filter { $0.characters.count >= minWordLength })).sorted()
      }
      .subscribe(onNext: { words in
        print(words)
      })
      .disposed(by: disposeBag)

    boardViewModel.activeCell.onNext(CellIndex(row: 0, col: 0))
    boardView.becomeFirstResponder()
  }
  
  private func makeWordLengthControl() -> NSSegmentedControl {
    let labels = ["?", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12+"]
    let control = NSSegmentedControl(labels: labels, trackingMode: .selectOne, target: self, action: #selector(wordLengthChosen(thing:)))
    control.translatesAutoresizingMaskIntoConstraints = false
    return control
  }
  
  private func makeButton() -> NSButton {
    let button = NSButton()
    button.stringValue = "Click"
    button.target = self
    button.action = #selector(buttonTapped(_:))
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
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
    statusView.isEditable = false
    return statusView
  }

  private func makeStatusViewModel(statusQueue: Observable<Status>, statusView: NSTextField) -> StatusViewModel {
    let statusViewModel = StatusViewModel(messages: statusQueue)
    statusViewModel.text.bind(to: statusView.rx.text).disposed(by: disposeBag)
    return statusViewModel
  }

  private func constrainViews(boardView: BoardView,
                              statusView: NSTextField,
                              wordLengthControl: NSSegmentedControl) {
    wordLengthControl.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    wordLengthControl.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    
    boardView.topAnchor.constraint(equalTo: wordLengthControl.bottomAnchor).isActive = true
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

  @objc public func buttonTapped(_: Any?) {
    var wl = try! wordLength.value() + 1
    if wl > 12 {
      wl = 3
    }
    status.onNext(.message("Only words with \(wl) letters"))
    wordLength.onNext(wl)
  }
  
  @objc public func wordLengthChosen(thing: Any?) {
    guard let control = thing as? NSSegmentedControl else { return }
    guard let label = control.label(forSegment: control.selectedSegment) else { return }
    
    guard let wl = Int(label) else { return }
    wordLength.onNext(wl)
    status.onNext(.message("Only words with \(wl) letters"))
  }

  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
}
