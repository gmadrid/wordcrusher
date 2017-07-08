//
//  WordListViewModel.swift
//  WordCrusher
//
//  Created by George Madrid on 7/7/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation
import RxSwift

// Acts as a data source for a tableView, as well.
class WordListViewModel: NSObject {
  let disposeBag = DisposeBag()

  // Output
  let wordListChanged: Observable<()>
  fileprivate let wordListSubject = PublishSubject<()>()

  fileprivate var wordList: [String] {
    didSet {
      wordListSubject.onNext(())
    }
  }

  init(wordList: Observable<[String]>) {
    wordListChanged = wordListSubject
    self.wordList = []

    super.init()

    wordList
      .map {
        // Remove dups by making a set first, then sort.
        Array(Set($0)).sorted()
      }
      .subscribe(onNext: { [weak self] lst in self?.wordList = lst })
      .disposed(by: disposeBag)
  }
}

extension WordListViewModel: NSTableViewDataSource {
  public func numberOfRows(in _: NSTableView) -> Int {
    return wordList.count
  }

  public func tableView(_: NSTableView, objectValueFor _: NSTableColumn?, row: Int) -> Any? {
    return wordList[row]
  }
}
