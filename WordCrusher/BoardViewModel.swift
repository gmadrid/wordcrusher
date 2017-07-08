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

private let doubleClickInterval: RxTimeInterval = 0.5

class BoardViewModel {
  let disposeBag = DisposeBag()
  let board: Board

  // Outputs
  var activeCell: ControlProperty<CellIndex?>
  var boardChanged: Observable<()>
  
  private typealias CellTimePair = (CellIndex, RxTime)

  // Inits
  init(board: Board,
       activeCell activeCellProperty: ControlProperty<CellIndex?>,
       clickedCell: Observable<CellIndex?>,
       charInput: Observable<Character>) {
    self.board = board
    activeCell = activeCellProperty

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
    
    clickedCell
      .scan(ArraySlice<CellTimePair>()) { (acc, maybeCellIndex) in
        guard let cellIndex = maybeCellIndex else { return [] }
        let newSlice = acc + [(cellIndex, Date())]
        return newSlice.suffix(2)
      }
      .filter { arr in
        guard arr.count == 2 else { return false }
        
        let pair1 = arr[arr.startIndex]
        let pair2 = arr[arr.index(after: arr.startIndex)]
        
        // TODO: deal with the system's double click interval
        // Pass through double clicks that 
        //   a) are in the same cell, and 
        //   b) less than the double click interval apart.
        return pair1.0 == pair2.0 && pair2.1.timeIntervalSince(pair1.1) < doubleClickInterval
      }
      .throttle(doubleClickInterval, scheduler: MainScheduler.instance)
      .map { $0.first!.0 }
      .subscribe({ cell in
        // Collapse the cell in here.
      })
      .disposed(by: disposeBag)
  }
}
