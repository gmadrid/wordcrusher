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

  // Outputs
  var activeCell: ControlProperty<CellIndex?>
  var boardChanged: Observable<()>

  // Inits
  init(board: Board,
       activeCell activeCellProperty: ControlProperty<CellIndex?>,
       clickedCell: Observable<CellIndex?>,
       charInput: Observable<Character>) {
    self.board = board
    self.activeCell = activeCellProperty

    let boardChanged = PublishSubject<()>()
    self.boardChanged = boardChanged.asObservable()

    // TODO: see if you can get this subscription out of here. I bet you can.
    charInput.withLatestFrom(activeCellProperty) { $0 }
      .subscribe(onNext: { pair in
        let (ch, activeCell_) = pair
        guard let activeCell = activeCell_ else { return }

        board.setChar(at: activeCell, ch: ch)

        let nextCell = board.nextCell(cellIndex: activeCell)
        activeCellProperty.onNext(nextCell)

        boardChanged.onNext(())
      })
      .disposed(by: disposeBag)
    
    clickedCell.distinctUntilChanged(==)
      .subscribe(onNext: { activeCellProperty.onNext($0) })
      .disposed(by: disposeBag)
  }
}
