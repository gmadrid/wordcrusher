//
//  SearchService.swift
//  WordCrusher
//
//  Created by George Madrid on 7/6/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation
import RxSwift

class SearchService {
  let disposeBag = DisposeBag()
  
  // Outputs
  let words: Observable<[String]>
  
  init(boardChanged: Observable<()>, trie: Observable<Trie>) {
    let wordsSubject = BehaviorSubject<[String]>(value: [String]())
    words = wordsSubject.asObservable()
    
    Observable.combineLatest(boardChanged.startWith(()), trie) { ($0, $1) }
      .map { _, trie -> () in
        return ()
      }
      .subscribe(onNext: {
      })
      .disposed(by: disposeBag)
  }
}
