//
//  NopDisposable.swift
//  RxSwift
//
//  Created by PowerMobile Team on 2/15/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

/// Represents a disposable that does nothing on disposal.
///
/// Nop = No Operation
fileprivate struct NopDisposable : Disposable {
 
    fileprivate static let noOp: Disposable = NopDisposable()
    
    fileprivate init() {
        
    }
    
    /// Does nothing.
    public func dispose() {
    }
}

extension Disposables {
    /**
     Creates a disposable that does nothing on disposal.
     */
    static public func create() -> Disposable {
        return NopDisposable.noOp
    }
}
