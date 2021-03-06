//
//  AppDelegate.swift
//  RxExample
//
//  Created by PowerMobile Team on 2/21/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if UIApplication.isInUITest {
            UIView.setAnimationsEnabled(false)
        }

        #if DEBUG
        _ = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                print("Resource count \(RxSwift.Resources.total)")
            })
        #endif

        return true
    }
}

