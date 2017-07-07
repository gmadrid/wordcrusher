//
//  StatusViewModel.swift
//  WordCrusher
//
//  Created by George Madrid on 7/6/17.
//  Copyright © 2017 George Madrid. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class StatusViewModel {
  // Outputs:
  let text: Observable<String?>

  init(messages: Observable<Status>) {
      text = messages
        .throttle(0.25, scheduler: MainScheduler.asyncInstance)
        .map { $0.msg() }
  }
}
