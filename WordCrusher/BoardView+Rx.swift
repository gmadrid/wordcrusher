//
//  BoardView+Rx.swift
//  WordCrusher
//
//  Created by George Madrid on 6/24/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base: BoardView {
  public var delegate: DelegateProxy {
    return BoardViewDelegateProxy.proxyForObject(base)
  }

  /** The current active cell in the board. */
  public var activeCell: ControlProperty<CellIndex?> {
    let delegate = BoardViewDelegateProxy.proxyForObject(base)

    let source = Observable.deferred { [weak boardView = self.base] in
      delegate.activeCellSubject.startWith(boardView?.activeCell)
    }.takeUntil(deallocated)

    let observer = UIBindingObserver(UIElement: base) { (control, value: CellIndex?) in
      control.activeCell = value
    }

    return ControlProperty(values: source, valueSink: observer.asObserver())
  }

  /** Character stream of typed characters received by Board while in responder chain. */
  public var ch: ControlEvent<Character> {
    let delegate = BoardViewDelegateProxy.proxyForObject(base)
    return ControlEvent(events: delegate.chSubject.asObservable())
  }

  /** Stream of mouse clicks translated into CellIndex? */
  public var click: ControlEvent<CellIndex?> {
    let delegate = BoardViewDelegateProxy.proxyForObject(base)
    return ControlEvent(events: delegate.clickSubject.asObserver())
  }
}

class BoardViewDelegateProxy: DelegateProxy, BoardViewDelegate, DelegateProxyType {
  public private(set) weak var boardView: BoardView?

  fileprivate let activeCellSubject = PublishSubject<CellIndex?>()
  fileprivate let chSubject = PublishSubject<Character>()
  fileprivate let clickSubject = PublishSubject<CellIndex?>()

  public required init(parentObject: AnyObject) {
    boardView = castOrFatalError(parentObject)
    super.init(parentObject: parentObject)
  }

  class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
    let boardView: BoardView = castOrFatalError(object)
    return boardView.delegate as AnyObject
  }

  class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
    let boardView: BoardView = castOrFatalError(object)
    boardView.delegate = delegate as? BoardViewDelegate
  }

  public func activeCellChangedTo(row: Int, col: Int) {
    postCell(row: row, col: col, to: activeCellSubject)
  }

  public func clickInCell(row: Int, col: Int) {
    postCell(row: row, col: col, to: clickSubject)
  }

  public func postCell<O: ObserverType>(row: Int, col: Int, to sequence: O) where O.E == CellIndex? {
    let cell: CellIndex?
    if row < 0 || col < 0 {
      cell = nil
    } else {
      cell = CellIndex(row: row, col: col)
    }
    sequence.onNext(cell)
  }

  public func keyReceived(chs: String) {
    if let ch = chs.characters.first {
      chSubject.onNext(ch)
    }
  }
}
