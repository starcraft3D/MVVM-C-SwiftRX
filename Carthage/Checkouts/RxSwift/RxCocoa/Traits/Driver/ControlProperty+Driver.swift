//
//  ControlProperty+Driver.swift
//  RxCocoa
//
//  Created by PowerMobile Team on 9/19/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

#if !RX_NO_MODULE
import RxSwift
#endif

extension ControlProperty {
    /// Converts `ControlProperty` to `Driver` trait.
    ///
    /// `ControlProperty` already can't fail, so no special case needs to be handled.
    public func asDriver() -> Driver<E> {
        return self.asDriver { (error) -> Driver<E> in
            #if DEBUG
                rxFatalError("Somehow driver received error from a source that shouldn't fail.")
            #else
                return Driver.empty()
            #endif
        }
    }
}
