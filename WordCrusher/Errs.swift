//
//  Errs.swift
//  WordCrusher
//
//  Created by George Madrid on 6/22/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation

enum Errs: Error {
  case contentsIsWrongLength
  case fileNotFound(String)
  case indexOutOfRange
}
