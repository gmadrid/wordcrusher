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
      
    case .equal(let rhs):
      return lhs == rhs
      
    case .lessEq(let rhs):
      return lhs <= rhs
      
    case .greaterEq(let rhs):
      return lhs >= rhs
    }
  }
}
