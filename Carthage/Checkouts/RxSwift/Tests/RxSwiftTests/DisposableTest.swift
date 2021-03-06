//
//  DisposableTest.swift
//  Tests
//
//  Created by PowerMobile Team on 2/8/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

import class Dispatch.DispatchQueue
#if os(Linux)
    import func Glibc.random
#else
    import func Foundation.arc4random_uniform
#endif

class DisposableTest : RxTest {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

// action
extension DisposableTest
{
    func testActionDisposable() {
        var counter = 0
        
        let disposable = Disposables.create {
            counter = counter + 1
        }
        
        XCTAssert(counter == 0)
        disposable.dispose()
        XCTAssert(counter == 1)
        disposable.dispose()
        XCTAssert(counter == 1)
    }
}

// hot disposable
extension DisposableTest {
    func testHotObservable_Disposing() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(110, 1),
            next(180, 2),
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7),
            next(450, 8),
            next(470, 9),
            next(560, 10),
            next(580, 11),
            completed(600)
            ])
        
        let res = scheduler.start(disposed: 400) { () -> Observable<Int> in
            return xs.asObservable()
        }
        
        XCTAssertEqual(res.events, [
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
    }
}

// composite disposable
extension DisposableTest
{
    func testCompositeDisposable_TestNormal() {
        var numberDisposed = 0
        let compositeDisposable = CompositeDisposable()
        
        let result1 = compositeDisposable.insert(Disposables.create {
            numberDisposed += 1
        })
        
        _ = compositeDisposable.insert(Disposables.create {
            numberDisposed += 1
        })
        
        XCTAssertEqual(numberDisposed, 0)
        XCTAssertEqual(compositeDisposable.count, 2)
        XCTAssertTrue(result1 != nil)
        
        compositeDisposable.dispose()
        XCTAssertEqual(numberDisposed, 2)
        XCTAssertEqual(compositeDisposable.count, 0)
        
        let result = compositeDisposable.insert(Disposables.create {
            numberDisposed += 1
        })

        XCTAssertEqual(numberDisposed, 3)
        XCTAssertEqual(compositeDisposable.count, 0)
        XCTAssertTrue(result == nil)
    }
    
    func testCompositeDisposable_TestInitWithNumberOfDisposables() {
        var numberDisposed = 0
        
        let disposable1 = Disposables.create {
            numberDisposed += 1
        }
        let disposable2 = Disposables.create {
            numberDisposed += 1
        }
        let disposable3 = Disposables.create {
            numberDisposed += 1
        }
        let disposable4 = Disposables.create {
            numberDisposed += 1
        }
        let disposable5 = Disposables.create {
            numberDisposed += 1
        }

        let compositeDisposable = CompositeDisposable(disposable1, disposable2, disposable3, disposable4, disposable5)
        
        XCTAssertEqual(numberDisposed, 0)
        XCTAssertEqual(compositeDisposable.count, 5)
        
        compositeDisposable.dispose()
        XCTAssertEqual(numberDisposed, 5)
        XCTAssertEqual(compositeDisposable.count, 0)
    }
    
    func testCompositeDisposable_TestRemoving() {
        var numberDisposed = 0
        let compositeDisposable = CompositeDisposable()
        
        let result1 = compositeDisposable.insert(Disposables.create {
            numberDisposed += 1
            })
        
        let result2 = compositeDisposable.insert(Disposables.create {
            numberDisposed += 1
            })
        
        XCTAssertEqual(numberDisposed, 0)
        XCTAssertEqual(compositeDisposable.count, 2)
        XCTAssertTrue(result1 != nil)
        
        compositeDisposable.remove(for: result2!)

        XCTAssertEqual(numberDisposed, 1)
        XCTAssertEqual(compositeDisposable.count, 1)
     
        compositeDisposable.dispose()

        XCTAssertEqual(numberDisposed, 2)
        XCTAssertEqual(compositeDisposable.count, 0)
    }
    
    func testDisposables_TestCreateWithNumberOfDisposables() {
        var numberDisposed = 0
        
        let disposable1 = Disposables.create {
            numberDisposed += 1
        }
        let disposable2 = Disposables.create {
            numberDisposed += 1
        }
        let disposable3 = Disposables.create {
            numberDisposed += 1
        }
        let disposable4 = Disposables.create {
            numberDisposed += 1
        }
        let disposable5 = Disposables.create {
            numberDisposed += 1
        }
        
        let disposable = Disposables.create(disposable1, disposable2, disposable3, disposable4, disposable5)
        
        XCTAssertEqual(numberDisposed, 0)
        
        disposable.dispose()
        XCTAssertEqual(numberDisposed, 5)
    }
}

extension DisposableTest {
    func testRefCountDisposable_RefCounting() {
        let d = BooleanDisposable()
        let r = RefCountDisposable(disposable: d)
        
        XCTAssertEqual(r.isDisposed, false)
        
        let d1 = r.retain()
        let d2 = r.retain()
        
        XCTAssertEqual(d.isDisposed, false)
        
        d1.dispose()
        XCTAssertEqual(d.isDisposed, false)
        
        d2.dispose()
        XCTAssertEqual(d.isDisposed, false)
        
        r.dispose()
        XCTAssertEqual(d.isDisposed, true)
        
        let d3 = r.retain()
        d3.dispose()
    }
    
    func testRefCountDisposable_PrimaryDisposesFirst() {
        let d = BooleanDisposable()
        let r = RefCountDisposable(disposable: d)
        
        XCTAssertEqual(r.isDisposed, false)
        
        let d1 = r.retain()
        let d2 = r.retain()
        
        XCTAssertEqual(d.isDisposed, false)
        
        d1.dispose()
        XCTAssertEqual(d.isDisposed, false)
        
        r.dispose()
        XCTAssertEqual(d.isDisposed, false)
        
        d2.dispose()
        XCTAssertEqual(d.isDisposed, true)
        
    }
}

// single assignment disposable
extension DisposableTest {
    func testSingleAssignmentDisposable_firstDisposedThenSet() {
        let singleAssignmentDisposable = SingleAssignmentDisposable()

        singleAssignmentDisposable.dispose()

        let testDisposable = TestDisposable()

        singleAssignmentDisposable.setDisposable(testDisposable)

        XCTAssertEqual(testDisposable.count, 1)
        singleAssignmentDisposable.dispose()
        XCTAssertEqual(testDisposable.count, 1)
    }

    func testSingleAssignmentDisposable_firstSetThenDisposed() {
        let singleAssignmentDisposable = SingleAssignmentDisposable()

        let testDisposable = TestDisposable()

        singleAssignmentDisposable.setDisposable(testDisposable)

        XCTAssertEqual(testDisposable.count, 0)
        singleAssignmentDisposable.dispose()
        XCTAssertEqual(testDisposable.count, 1)

        singleAssignmentDisposable.dispose()
        XCTAssertEqual(testDisposable.count, 1)
    }

    func testSingleAssignmentDisposable_stress() {
        var count: AtomicInt = 0

        let queue = DispatchQueue(label: "dispose", qos: .default, attributes: [.concurrent])

        for _ in 0 ..< 100 {
            for _ in 0 ..< 10 {
                let expectation = self.expectation(description: "1")
                let singleAssignmentDisposable = SingleAssignmentDisposable()
                let disposable = Disposables.create {
                    _ = AtomicIncrement(&count)
                    expectation.fulfill()
                }
                #if os(Linux)
                    let roll = Glibc.random() & 1
                #else
                    let roll = arc4random_uniform(2) 
                #endif
                if roll == 0 {
                    queue.async {
                        singleAssignmentDisposable.setDisposable(disposable)
                    }
                    queue.async {
                        singleAssignmentDisposable.dispose()
                    }
                }
                else {
                    queue.async {
                        singleAssignmentDisposable.dispose()
                    }
                    queue.async {
                        singleAssignmentDisposable.setDisposable(disposable)
                    }
                }
            }
        }

        self.waitForExpectations(timeout: 1.0) { e in
            XCTAssertNil(e)
        }

        XCTAssertTrue(AtomicFlagSet(10000, &count))
    }
}

fileprivate class TestDisposable: Disposable {
    var count = 0
    func dispose() {
        count += 1
    }
}
