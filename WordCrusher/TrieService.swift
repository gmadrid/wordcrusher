//
//  TrieService.swift
//  WordCrusher
//
//  Created by George Madrid on 7/6/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import StreamReader

private let defaultWordList = "/usr/share/dict/words"

class TrieService {
  let disposeBag = DisposeBag()

  // Output
  let trie: Observable<Trie>
  let status: Observable<Status>

  init() {
    let statusSubject = PublishSubject<Status>()
    status = statusSubject.asObservable()

    let trieSubject = PublishSubject<Trie>()
    trie = trieSubject.asObservable()

    Observable.just(defaultWordList)
      .map { (path: String) -> Trie in
        let trie = Trie()
        let wordStream = StreamReader(path: path)!

        // TODO: error
        statusSubject.onNext(.message("Reading word list..."))
        var lineNumber = 0
        while let line = wordStream.nextLine() {
          if line.characters.count > 2 {
            trie.insert(word: line)
          }
          lineNumber += 1
          statusSubject.onNext(.message("Reading word list...\(lineNumber)"))
        }
        statusSubject.onNext(.none)
        return trie
      }
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .subscribe(onNext: {
        trieSubject.onNext($0)
      })
      .disposed(by: disposeBag)
  }
}
