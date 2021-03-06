//
//  Never.swift
//  RxSwift
//
//  Created by PowerMobile Team on 8/30/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

extension Observable {

    /**
     Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

     - seealso: [never operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: An observable sequence whose observers will never get called.
     */
    public static func never() -> Observable<E> {
        return NeverProducer()
    }
}

final fileprivate class NeverProducer<Element> : Producer<Element> {
    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == Element {
        return Disposables.create()
    }
}
