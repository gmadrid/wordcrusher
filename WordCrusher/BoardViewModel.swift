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
  
  var activeCell_: Observable<Board.CellIndex> {
    return activeCellSubject.asObservable()
  }
  private let activeCellSubject = BehaviorSubject(value: Board.CellIndex(row: 0, col: 0))
  
  var changedCell_: Observable<Board.CellIndex> {
    return changedCellSubject.asObservable()
  }
  private let changedCellSubject = PublishSubject<Board.CellIndex>()
  
  init(board: Board) {
    boardSubject = BehaviorSubject(value: board)
  }
  
  // TODO: This is kind of ugly. Can you fix it?
  func setActiveCell(index: Board.CellIndex) {
    activeCellSubject.onNext(index)
  }
}
