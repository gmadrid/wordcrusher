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
  let disposeBag = DisposeBag()
  let status = Status.none

  // Inputs
  let messages: Observable<Status>

  // Outputs:
  let text: Observable<String?>

  init(messages: Observable<Status>) {
    self.messages = messages

    let textSubject = PublishSubject<String?>()
    text = textSubject

    messages.throttle(0.25, scheduler: MainScheduler.asyncInstance)
      .subscribe(onNext: { st in
        textSubject.onNext(st.msg())
      })
      .disposed(by: disposeBag)
  }
}
