//
//  Util.swift
//  WordCrusher
//
//  Created by George Madrid on 6/23/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Cocoa
import Foundation

class Util {

  static func distanceSquared(p1: CGPoint, p2: CGPoint) -> CGFloat {
    let dx = p1.x - p2.x
    let dy = p1.y - p2.y
    return dx * dx + dy * dy
  }
}

extension NSColor {
  convenience init(hexColor: String) {
    // TODO: this is very brittle. Doesn't allow leading #
    var startIndex = hexColor.startIndex
    var endIndex = hexColor.index(startIndex, offsetBy: 2)
    let r = hexColor.substring(with: startIndex ..< endIndex)

    startIndex = endIndex
    endIndex = hexColor.index(startIndex, offsetBy: 2)
    let g = hexColor.substring(with: startIndex ..< endIndex)

    startIndex = endIndex
    endIndex = hexColor.index(startIndex, offsetBy: 2)
    let b = hexColor.substring(with: startIndex ..< endIndex)

    let ri = UInt8(r, radix: 16) ?? 0
    let gi = UInt8(g, radix: 16) ?? 0
    let bi = UInt8(b, radix: 16) ?? 0

    let rf = CGFloat(ri) / 255.0
    let gf = CGFloat(gi) / 255.0
    let bf = CGFloat(bi) / 255.0

    self.init(red: rf, green: gf, blue: bf, alpha: 1.0)
  }
}

func castOrFatalError<T>(_ value: Any!) -> T {
  let maybeResult: T? = value as? T
  guard let result = maybeResult else {
    fatalError("Failure converting from \(value) to \(T.self)")
  }

  return result
}
