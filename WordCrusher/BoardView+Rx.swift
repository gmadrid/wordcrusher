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
  
  public var ch: ControlEvent<Character> {
    let delegate = BoardViewDelegateProxy.proxyForObject(base)
    return ControlEvent(events: delegate.chSubject.asObservable())
  }
}

class BoardViewDelegateProxy: DelegateProxy, BoardViewDelegate, DelegateProxyType {
  private(set) public weak var boardView: BoardView?

  fileprivate let activeCellSubject = PublishSubject<CellIndex?>()
  fileprivate let chSubject = PublishSubject<Character>()

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
    let activeCell: CellIndex?
    if row < 0 || col < 0 {
      activeCell = nil
    } else {
      activeCell = CellIndex(row: row, col: col)
    }
    activeCellSubject.on(.next(activeCell))
  }
  
  public func keyReceived(chs: String) {
    if let ch = chs.characters.first {
      chSubject.onNext(ch)
    }
  }
}
