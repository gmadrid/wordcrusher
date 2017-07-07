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

  init(board: Board, boardChanged: Observable<()>, trie: Observable<Trie>) {
    words = Observable.combineLatest(boardChanged.startWith(()), trie) { $1 }
      .map { board.searchAll(in: $0) }
      .startWith([String]())
      .shareReplay(1)
  }
}
