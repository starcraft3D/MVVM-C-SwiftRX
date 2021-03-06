//
//  ObservableConvertibleType+Driver.swift
//  RxCocoa
//
//  Created by PowerMobile Team on 9/19/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

#if !RX_NO_MODULE
import RxSwift
#endif

extension ObservableConvertibleType {
    /**
    Converts anything convertible to `Observable` to `Driver` unit.
    
    - parameter onErrorJustReturn: Element to return in case of error and after that complete the sequence.
    - returns: Driving observable sequence.
    */
    public func asDriver(onErrorJustReturn: E) -> Driver<E> {
        let source = self
            .asObservable()
            .observeOn(DriverSharingStrategy.scheduler)
            .catchErrorJustReturn(onErrorJustReturn)
        return Driver(source)
    }
    
    /**
    Converts anything convertible to `Observable` to `Driver` unit.
    
    - parameter onErrorDriveWith: Driver that continues to drive the sequence in case of error.
    - returns: Driving observable sequence.
    */
    public func asDriver(onErrorDriveWith: Driver<E>) -> Driver<E> {
        let source = self
            .asObservable()
            .observeOn(DriverSharingStrategy.scheduler)
            .catchError { _ in
                onErrorDriveWith.asObservable()
            }
        return Driver(source)
    }

    /**
    Converts anything convertible to `Observable` to `Driver` unit.
    
    - parameter onErrorRecover: Calculates driver that continues to drive the sequence in case of error.
    - returns: Driving observable sequence.
    */
    public func asDriver(onErrorRecover: @escaping (_ error: Swift.Error) -> Driver<E>) -> Driver<E> {
        let source = self
            .asObservable()
            .observeOn(DriverSharingStrategy.scheduler)
            .catchError { error in
                onErrorRecover(error).asObservable()
            }
        return Driver(source)
    }
}
