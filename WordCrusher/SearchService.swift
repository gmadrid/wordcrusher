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
  // Outputs
  let words: Observable<[String]>

  init(board: Board,
       boardChanged: Observable<()>,
       trie: Observable<Trie>,
       wordLength: Observable<Int>) {
    words = Observable.combineLatest(boardChanged.startWith(()), trie, wordLength) { ($1, $2) }
      .map { (trie, wordLength) in
        return board.searchAll(in: trie).filter { s in s.characters.count == wordLength }
      }
      .startWith([String]())
      .shareReplay(1)
  }
}
