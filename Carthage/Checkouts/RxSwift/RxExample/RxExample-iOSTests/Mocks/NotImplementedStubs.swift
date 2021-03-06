//
//  NotImplementedStubs.swift
//  RxExample
//
//  Created by PowerMobile Team on 12/29/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

import RxSwift
import RxTest

import func Foundation.arc4random

func genericFatal<T>(_ message: String) -> T {
    if -1 == Int(arc4random() % 4) {
        print("This is hack to remove warning")
    }
    _ = fatalError(message)
}

// MARK: Generic support code

// MARK: Not implemented stubs

func notImplemented<T1, T2>() -> (T1) -> Observable<T2> {
    return { _ -> Observable<T2> in
        return genericFatal("Not implemented")
    }
}

func notImplementedSync<T1>() -> (T1) -> Void {
    return { _ in
        genericFatal("Not implemented")
    }
}
