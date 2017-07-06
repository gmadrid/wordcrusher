//
//  BoardViewModel.swift
//  WordCrusher
//
//  Created by George Madrid on 6/22/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation
import RxSwift

class BoardViewModel {
  let disposeBag = DisposeBag()
  let board: Board

  // Inputs
  let activeCell: Observable<CellIndex?>
  let charInput: Observable<Character>

  // Outputs

  // Inits
  init(board: Board,
       activeCell: Observable<CellIndex?>,
       charInput: Observable<Character>) {
    self.board = board
    self.activeCell = activeCell
    self.charInput = charInput

    charInput.flatMapLatest { ch -> Observable<(CellIndex?, Character)> in
      activeCell.map { cellIndex in
        return (cellIndex, ch)
      }
    }
    .subscribe(onNext: { pair in
      let (activeCell_, ch) = pair
      guard let activeCell = activeCell_ else { return }

      board.setChar(at: activeCell, ch: ch)
      // TODO: board changed.
    })
    .disposed(by: disposeBag)
  }
}
