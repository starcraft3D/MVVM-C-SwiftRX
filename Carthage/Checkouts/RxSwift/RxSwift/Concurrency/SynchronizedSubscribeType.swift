//
//  SynchronizedSubscribeType.swift
//  RxSwift
//
//  Created by PowerMobile Team on 10/25/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

protocol SynchronizedSubscribeType : class, ObservableType, Lock {
    func _synchronized_subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == E
}

extension SynchronizedSubscribeType {
    func synchronizedSubscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == E {
        lock(); defer { unlock() }
        return _synchronized_subscribe(observer)
    }
}
