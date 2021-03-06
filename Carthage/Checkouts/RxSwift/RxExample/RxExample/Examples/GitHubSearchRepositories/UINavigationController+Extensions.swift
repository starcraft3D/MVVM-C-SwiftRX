//
//  UINavigationController+Extensions.swift
//  RxExample
//
//  Created by PowerMobile Team on 12/13/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct Colors {
    static let offlineColor = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
    static let onlineColor = nil as UIColor?
}

extension Reactive where Base: UINavigationController {
    var isOffline: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: base) { navigationController, isOffline in
            navigationController.navigationBar.barTintColor = isOffline
                ? Colors.offlineColor
                : Colors.onlineColor
        }
    }
}
