//
//  UIRefreshControl+Rx.swift
//  RxCocoa
//
//  Created by Yosuke Ishikawa on 1/31/16.
//  Copyright © 2016 PowerMobile Team. All rights reserved.
//

#if os(iOS)
import UIKit

#if !RX_NO_MODULE
import RxSwift
#endif

extension Reactive where Base: UIRefreshControl {

    /// Bindable sink for `beginRefreshing()`, `endRefreshing()` methods.
    @available(*, deprecated, renamed: "isRefreshing")
    public var refreshing: UIBindingObserver<Base, Bool> {
        return self.isRefreshing
    }

    /// Bindable sink for `beginRefreshing()`, `endRefreshing()` methods.
    public var isRefreshing: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { refreshControl, refresh in
            if refresh {
                refreshControl.beginRefreshing()
            } else {
                refreshControl.endRefreshing()
            }
        }
    }

}

#endif
