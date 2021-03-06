//
//  RxMutableBox.swift
//  RxSwift
//
//  Created by PowerMobile Team on 5/22/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

/// Creates mutable reference wrapper for any type.
final class RxMutableBox<T> : CustomDebugStringConvertible {
    /// Wrapped value
    var value : T
    
    /// Creates reference wrapper for `value`.
    ///
    /// - parameter value: Value to wrap.
    init (_ value: T) {
        self.value = value
    }
}

extension RxMutableBox {
    /// - returns: Box description.
    var debugDescription: String {
        return "MutatingBox(\(self.value))"
    }
}
