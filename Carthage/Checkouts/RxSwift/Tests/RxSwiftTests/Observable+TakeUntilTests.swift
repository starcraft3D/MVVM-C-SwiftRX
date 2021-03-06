//
//  Observable+TakeUntilTests.swift
//  Tests
//
//  Created by PowerMobile Team on 4/29/17.
//  Copyright © 2017 PowerMobile Team. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableTakeUntilTest : RxTest {
}

extension ObservableTakeUntilTest {
    func testTakeUntil_Preempt_SomeData_Next() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(225, 99),
            completed(230)
        ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
    
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            completed(225)
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testTakeUntil_Preempt_SomeData_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            error(225, testError),
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }

        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            error(225, testError)
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testTakeUntil_NoPreempt_SomeData_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            completed(225)
        ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testTakeUntil_NoPreempt_SomeData_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testTakeUntil_Preempt_Never_Next() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(225, 2),
            completed(250)
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            completed(225)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testTakeUntil_Preempt_Never_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            error(225, testError)
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            error(225, testError)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }

    func testTakeUntil_NoPreempt_Never_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            completed(225)
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testTakeUntil_NoPreempt_Never_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 1000)
            ])
    }
    
    func testTakeUntil_Preempt_BeforeFirstProduced() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(230, 2),
            completed(240)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(220)
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            completed(210)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 210)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 210)
            ])
    }
    
    func testTakeUntil_Preempt_BeforeFirstProduced_RemainSilentAndProperDisposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            error(215, testError),
            completed(240)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(220)
            ])
        
        var sourceNotDisposed = false
        
        let res = scheduler.start {
            l.do(onNext: { _ in sourceNotDisposed = true }).takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            completed(210)
            ])
        
        XCTAssertFalse(sourceNotDisposed)
    }
    
    func testTakeUntil_NoPreempt_AfterLastProduced_ProperDisposedSigna() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(230, 2),
            completed(240)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(250, 2),
            completed(260)
            ])
        
        var sourceNotDisposed = false
        
        let res = scheduler.start {
            l.takeUntil(r.do(onNext: { _ in sourceNotDisposed = true }))
        }
        
        XCTAssertEqual(res.events, [
            next(230, 2),
            completed(240)
            ])
        
        XCTAssertFalse(sourceNotDisposed)
    }
    
    func testTakeUntil_Error_Some() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            error(225, testError)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(240, 2),
            ])
        
        let sourceNotDisposed = false
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            error(225, testError),
            ])
        
        XCTAssertFalse(sourceNotDisposed)
    }

    #if TRACE_RESOURCES
        func testTakeUntil1ReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable.just(1).delay(10, scheduler: scheduler).takeUntil(Observable.just(1)).subscribe()
            scheduler.start()
        }

        func testTakeUntil2ReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable.just(1).takeUntil(Observable.just(1).delay(10, scheduler: scheduler)).subscribe()
            scheduler.start()
        }

        func testTakeUntil1ReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.never().timeout(20, scheduler: scheduler).takeUntil(Observable<Int>.never()).subscribe()
            scheduler.start()
        }

        func testTakeUntil2ReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.never().takeUntil(Observable<Int>.never().timeout(20, scheduler: scheduler)).subscribe()
            scheduler.start()
        }
    #endif
}
