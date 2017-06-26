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

  public var activeCellChanged: ControlEvent<CellIndex?> {
    let source = delegate
      .methodInvoked(#selector(BoardViewDelegate.activeCellChangedTo(row:col:)))
      .map { parameters -> CellIndex? in
        let row = parameters[0] as! Int, col = parameters[1] as! Int
        if row < 0 || col < 0 { return nil }
        return CellIndex(row: row, col: col)
      }
    return ControlEvent(events: source)
  }
}

class BoardViewDelegateProxy: DelegateProxy, BoardViewDelegate, DelegateProxyType {
  class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
    let boardView: BoardView = (object as? BoardView)!
    return boardView.delegate as AnyObject
  }

  class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
    let boardView: BoardView = (object as? BoardView)!
    boardView.delegate = delegate as? BoardViewDelegate
  }
}
