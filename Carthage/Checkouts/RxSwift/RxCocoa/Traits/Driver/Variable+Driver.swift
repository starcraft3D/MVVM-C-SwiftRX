//
//  Variable+Driver.swift
//  RxCocoa
//
//  Created by PowerMobile Team on 12/28/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

#if !RX_NO_MODULE
    import RxSwift
#endif

extension Variable {
    /// Converts `Variable` to `Driver` unit.
    ///
    /// - returns: Driving observable sequence.
    public func asDriver() -> Driver<E> {
        let source = self.asObservable()
            .observeOn(DriverSharingStrategy.scheduler)
        return Driver(source)
    }
}
