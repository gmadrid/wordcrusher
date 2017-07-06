//
//  BoardViewModel.swift
//  WordCrusher
//
//  Created by George Madrid on 6/22/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class BoardViewModel {
  let disposeBag = DisposeBag()
  let board: Board

  // Inputs
  let activeCell: ControlProperty<CellIndex?>
  let charInput: Observable<Character>

  // Outputs
  var boardChanged: Observable<()>

  // Inits
  init(board: Board,
       activeCell: ControlProperty<CellIndex?>,
       charInput: Observable<Character>) {
    self.board = board
    self.activeCell = activeCell
    self.charInput = charInput

    let boardChanged = PublishSubject<()>()
    self.boardChanged = boardChanged.asObservable()

    charInput.withLatestFrom(activeCell) { $0 }
      .subscribe(onNext: { [weak self] pair in
        let (ch, activeCell_) = pair
        guard let activeCell = activeCell_ else { return }

        board.setChar(at: activeCell, ch: ch)

        let nextCell = board.nextCell(cellIndex: activeCell)
        self?.activeCell.onNext(nextCell)

        boardChanged.onNext(())
      })
      .disposed(by: disposeBag)
  }
}
