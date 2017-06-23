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
  var board_: Observable<Board> {
    return boardSubject.asObservable()
  }
  private let boardSubject: BehaviorSubject<Board>
  
  var activeCell_ = Variable<Board.CellIndex>(Board.CellIndex.zero)
  
  init(board: Board) {
    boardSubject = BehaviorSubject(value: board)
  }
}
