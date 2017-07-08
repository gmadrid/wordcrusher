//
//  MatchSpec.swift
//  WordCrusher
//
//  Created by George Madrid on 7/7/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation

enum MatchSpec<T> where T: Comparable {
  case all
  case equal(rhs: T)
  case lessEq(rhs: T)
  case greaterEq(rhs: T)

  func matches(lhs: T) -> Bool {
    switch self {
    case .all:
      return true

    case let .equal(rhs):
      return lhs == rhs

    case let .lessEq(rhs):
      return lhs <= rhs

    case let .greaterEq(rhs):
      return lhs >= rhs
    }
  }
}
