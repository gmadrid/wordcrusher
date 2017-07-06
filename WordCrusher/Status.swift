//
//  Status.swift
//  WordCrusher
//
//  Created by George Madrid on 7/6/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation

enum Status {
  case message(String)
  case none
  
  func msg() -> String? {
    if case .message(let msg) = self { return msg } else { return nil }
  }
}
