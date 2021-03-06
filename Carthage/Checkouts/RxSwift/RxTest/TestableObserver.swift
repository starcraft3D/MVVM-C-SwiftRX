//
//  TestableObserver.swift
//  RxTest
//
//  Created by PowerMobile Team on 2/15/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

import RxSwift

/// Observer that records events together with virtual time when they were received.
public final class TestableObserver<ElementType>
    : ObserverType {
    public typealias Element = ElementType
    
    fileprivate let _scheduler: TestScheduler

    /// Recorded events.
    public fileprivate(set) var events = [Recorded<Event<Element>>]()
    
    init(scheduler: TestScheduler) {
        _scheduler = scheduler
    }

    /// Notify observer about sequence event.
    ///
    /// - parameter event: Event that occurred.
    public func on(_ event: Event<Element>) {
        events.append(Recorded(time: _scheduler.clock, value: event))
    }
}
