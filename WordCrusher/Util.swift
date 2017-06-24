//
//  Util.swift
//  WordCrusher
//
//  Created by George Madrid on 6/23/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation

class Util {

  static func distanceSquared(p1: CGPoint, p2: CGPoint) -> CGFloat {
    let dx = p1.x - p2.x
    let dy = p1.y - p2.y
    return dx * dx + dy * dy
  }
  
}
