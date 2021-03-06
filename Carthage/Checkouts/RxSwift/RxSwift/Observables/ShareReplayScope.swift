//
//  ShareReplayScope.swift
//  RxSwift
//
//  Created by PowerMobile Team on 5/28/17.
//  Copyright © 2017 PowerMobile Team. All rights reserved.
//

/// Subject lifetime scope
public enum SubjectLifetimeScope {
    /**
     **Each connection will have it's own subject instance to store replay events.**
     **Connections will be isolated from each another.**

     Configures the underlying implementation to behave equivalent to.
     
     ```
     source.multicast(makeSubject: { MySubject() }).refCount()
     ```

     **This is the recommended default.**

     This has the following consequences:
     * `retry` or `concat` operators will function as expected because terminating the sequence will clear internal state.
     * Each connection to source observable sequence will use it's own subject.
     * When the number of subscribers drops from 1 to 0 and connection to source sequence is disposed, subject will be cleared.

     
     ```
     let xs = Observable.deferred { () -> Observable<TimeInterval> in
             print("Performing work ...")
             return Observable.just(Date().timeIntervalSince1970)
         }
         .share(replay: 1, scope: .whileConnected)

     _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
     _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
     _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })

     ```

     Notice how time interval is different and `Performing work ...` is printed each time)
     
     ```
     Performing work ...
     next 1495998900.82141
     completed

     Performing work ...
     next 1495998900.82359
     completed

     Performing work ...
     next 1495998900.82444
     completed


     ```
     
     */
    case whileConnected

    /**
     **One subject will store replay events for all connections to source.**
     **Connections won't be isolated from each another.**

     Configures the underlying implementation behave equivalent to.

     ```
     source.multicast(MySubject()).refCount()
     ```
     
     This has the following consequences:
     * Using `retry` or `concat` operators after this operator usually isn't advised.
     * Each connection to source observable sequence will share the same subject.
     * After number of subscribers drops from 1 to 0 and connection to source observable sequence is dispose, this operator will 
       continue holding a reference to the same subject.
       If at some later moment a new observer initiates a new connection to source it can potentially receive
       some of the stale events received during previous connection.
     * After source sequence terminates any new observer will always immediatelly receive replayed elements and terminal event.
       No new subscriptions to source observable sequence will be attempted.

     ```
     let xs = Observable.deferred { () -> Observable<TimeInterval> in
             print("Performing work ...")
             return Observable.just(Date().timeIntervalSince1970)
         }
         .share(replay: 1, scope: .forever)

     _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
     _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
     _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
     ```
     
     Notice how time interval is the same, replayed, and `Performing work ...` is printed only once
     
     ```
     Performing work ...
     next 1495999013.76356
     completed

     next 1495999013.76356
     completed

     next 1495999013.76356
     completed
     ```
     
    */
    case forever
}

extension ObservableType {

    /**
     Returns an observable sequence that **shares a single subscription to the underlying sequence**, and immediately upon subscription replays  elements in buffer.
     
     This operator is equivalent to:
     * `.whileConnected`
     ```
     // Each connection will have it's own subject instance to store replay events.
     // Connections will be isolated from each another.
     source.multicast(makeSubject: { Replay.create(bufferSize: replay) }).refCount()
     ```
     * `.forever`
     ```
     // One subject will store replay events for all connections to source.
     // Connections won't be isolated from each another.
     source.multicast(Replay.create(bufferSize: replay)).refCount()
     ```
     
     It uses optimized versions of the operators for most common operations.

     - parameter replay: Maximum element count of the replay buffer.
     - parameter scope: Lifetime scope of sharing subject. For more information see `SubjectLifetimeScope` enum.

     - seealso: [shareReplay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)

     - returns: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence.
     */
    public func share(replay: Int = 0, scope: SubjectLifetimeScope)
        -> Observable<E> {
        switch scope {
        case .forever:
            switch replay {
            case 0: return self.multicast(PublishSubject()).refCount()
            default: return shareReplay(replay)
            }
        case .whileConnected:
            switch replay {
            case 0: return ShareWhileConnected(source: self.asObservable())
            case 1: return ShareReplay1WhileConnected(source: self.asObservable())
            default: return self.multicast(makeSubject: { ReplaySubject.create(bufferSize: replay) }).refCount()
            }
        }
    }
}

extension ObservableType {

    /**
     Returns an observable sequence that shares a single subscription to the underlying sequence, and immediately upon subscription replays latest element in buffer.

     This operator is a specialization of replay which creates a subscription when the number of observers goes from zero to one, then shares that subscription with all subsequent observers until the number of observers returns to zero, at which point the subscription is disposed.

     Unlike `shareReplay(bufferSize: Int)`, this operator will clear latest element from replay buffer in case number of subscribers drops from one to zero. In case sequence
     completes or errors out replay buffer is also cleared.

     - seealso: [shareReplay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)

     - returns: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence.
     */
    public func shareReplayLatestWhileConnected()
        -> Observable<E> {
        return ShareReplay1WhileConnected(source: self.asObservable())
    }
}

extension ObservableType {

    /**
     Returns an observable sequence that shares a single subscription to the underlying sequence, and immediately upon subscription replays maximum number of elements in buffer.

     This operator is a specialization of replay which creates a subscription when the number of observers goes from zero to one, then shares that subscription with all subsequent observers until the number of observers returns to zero, at which point the subscription is disposed.

     - seealso: [shareReplay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)

     - parameter bufferSize: Maximum element count of the replay buffer.
     - returns: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence.
     */
    public func shareReplay(_ bufferSize: Int)
        -> Observable<E> {
        if bufferSize == 1 {
            return ShareReplay1(source: self.asObservable())
        }
        else {
            return self.replay(bufferSize).refCount()
        }
    }
}

fileprivate final class ShareReplay1WhileConnectedConnection<Element>
    : ObserverType
    , SynchronizedUnsubscribeType {
    typealias E = Element
    typealias Observers = AnyObserver<Element>.s
    typealias DisposeKey = Observers.KeyType

    typealias Parent = ShareReplay1WhileConnected<Element>
    private let _parent: Parent
    private let _subscription = SingleAssignmentDisposable()

    private let _lock: RecursiveLock
    private var _disposed: Bool = false
    fileprivate var _observers = Observers()
    fileprivate var _element: Element?

    init(parent: Parent, lock: RecursiveLock) {
        _parent = parent
        _lock = lock

        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif
    }

    final func on(_ event: Event<E>) {
        _lock.lock()
        let observers = _synchronized_on(event)
        _lock.unlock()
        dispatch(observers, event)
    }

    final private func _synchronized_on(_ event: Event<E>) -> Observers {
        if _disposed {
            return Observers()
        }

        switch event {
        case .next(let element):
            _element = element
            return _observers
        case .error, .completed:
            let observers = _observers
            self._synchronized_dispose()
            return observers
        }
    }

    final func connect() {
        _subscription.setDisposable(_parent._source.subscribe(self))
    }

    final func _synchronized_subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == Element {
        _lock.lock(); defer { _lock.unlock() }
        if let element = _element {
            observer.on(.next(element))
        }

        let disposeKey = _observers.insert(observer.on)

        return SubscriptionDisposable(owner: self, key: disposeKey)
    }

    final private func _synchronized_dispose() {
        _disposed = true
        if _parent._connection === self {
            _parent._connection = nil
        }
        _observers = Observers()
        _subscription.dispose()
    }

    final func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        _lock.lock()
        _synchronized_unsubscribe(disposeKey)
        _lock.unlock()
    }

    @inline(__always)
    final private func _synchronized_unsubscribe(_ disposeKey: DisposeKey) {
        // if already unsubscribed, just return
        if self._observers.removeKey(disposeKey) == nil {
            return
        }

        if _observers.count == 0 {
            _synchronized_dispose()
        }
    }

    #if TRACE_RESOURCES
        deinit {
            _ = Resources.decrementTotal()
        }
    #endif
}

// optimized version of share replay for most common case
final fileprivate class ShareReplay1WhileConnected<Element>
    : Observable<Element> {

    fileprivate typealias Connection = ShareReplay1WhileConnectedConnection<Element>

    fileprivate let _source: Observable<Element>

    fileprivate let _lock = RecursiveLock()

    fileprivate var _connection: Connection?

    init(source: Observable<Element>) {
        self._source = source
    }

    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == E {
        _lock.lock()

        let connection = _synchronized_subscribe(observer)
        let count = connection._observers.count

        let disposable = connection._synchronized_subscribe(observer)
        
        if count == 0 {
            connection.connect()
        }

        _lock.unlock()

        return disposable
    }

    @inline(__always)
    private func _synchronized_subscribe<O : ObserverType>(_ observer: O) -> Connection where O.E == E {
        let connection: Connection

        if let existingConnection = _connection {
            connection = existingConnection
        }
        else {
            connection = ShareReplay1WhileConnectedConnection<Element>(
                parent: self,
                lock: _lock)
            _connection = connection
        }

        return connection
    }
}

fileprivate final class ShareWhileConnectedConnection<Element>
    : ObserverType
    , SynchronizedUnsubscribeType {
    typealias E = Element
    typealias Observers = AnyObserver<Element>.s
    typealias DisposeKey = Observers.KeyType

    typealias Parent = ShareWhileConnected<Element>
    private let _parent: Parent
    private let _subscription = SingleAssignmentDisposable()

    private let _lock: RecursiveLock
    private var _disposed: Bool = false
    fileprivate var _observers = Observers()

    init(parent: Parent, lock: RecursiveLock) {
        _parent = parent
        _lock = lock

        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif
    }

    final func on(_ event: Event<E>) {
        _lock.lock()
        let observers = _synchronized_on(event)
        _lock.unlock()
        dispatch(observers, event)
    }

    final private func _synchronized_on(_ event: Event<E>) -> Observers {
        if _disposed {
            return Observers()
        }

        switch event {
        case .next:
            return _observers
        case .error, .completed:
            let observers = _observers
            self._synchronized_dispose()
            return observers
        }
    }

    final func connect() {
        _subscription.setDisposable(_parent._source.subscribe(self))
    }

    final func _synchronized_subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == Element {
        _lock.lock(); defer { _lock.unlock() }

        let disposeKey = _observers.insert(observer.on)

        return SubscriptionDisposable(owner: self, key: disposeKey)
    }

    final private func _synchronized_dispose() {
        _disposed = true
        if _parent._connection === self {
            _parent._connection = nil
        }
        _observers = Observers()
        _subscription.dispose()
    }

    final func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        _lock.lock()
        _synchronized_unsubscribe(disposeKey)
        _lock.unlock()
    }

    @inline(__always)
    final private func _synchronized_unsubscribe(_ disposeKey: DisposeKey) {
        // if already unsubscribed, just return
        if self._observers.removeKey(disposeKey) == nil {
            return
        }

        if _observers.count == 0 {
            _synchronized_dispose()
        }
    }

    #if TRACE_RESOURCES
    deinit {
        _ = Resources.decrementTotal()
    }
    #endif
}

// optimized version of share replay for most common case
final fileprivate class ShareWhileConnected<Element>
    : Observable<Element> {

    fileprivate typealias Connection = ShareWhileConnectedConnection<Element>

    fileprivate let _source: Observable<Element>

    fileprivate let _lock = RecursiveLock()

    fileprivate var _connection: Connection?

    init(source: Observable<Element>) {
        self._source = source
    }

    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == E {
        _lock.lock()

        let connection = _synchronized_subscribe(observer)
        let count = connection._observers.count

        let disposable = connection._synchronized_subscribe(observer)

        if count == 0 {
            connection.connect()
        }

        _lock.unlock()

        return disposable
    }

    @inline(__always)
    private func _synchronized_subscribe<O : ObserverType>(_ observer: O) -> Connection where O.E == E {
        let connection: Connection

        if let existingConnection = _connection {
            connection = existingConnection
        }
        else {
            connection = ShareWhileConnectedConnection<Element>(
                parent: self,
                lock: _lock)
            _connection = connection
        }
        
        return connection
    }
}

// optimized version of share replay for most common case
final fileprivate class ShareReplay1<Element>
    : Observable<Element>
    , ObserverType
    , SynchronizedUnsubscribeType {

    typealias Observers = AnyObserver<Element>.s
    typealias DisposeKey = Observers.KeyType

    private let _source: Observable<Element>

    private let _lock = RecursiveLock()

    private var _connection: SingleAssignmentDisposable?
    private var _element: Element?
    private var _stopped = false
    private var _stopEvent = nil as Event<Element>?
    private var _observers = Observers()

    init(source: Observable<Element>) {
        self._source = source
    }

    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == E {
        _lock.lock()
        let result = _synchronized_subscribe(observer)
        _lock.unlock()
        return result
    }

    func _synchronized_subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == E {
        if let element = self._element {
            observer.on(.next(element))
        }

        if let stopEvent = self._stopEvent {
            observer.on(stopEvent)
            return Disposables.create()
        }

        let initialCount = self._observers.count

        let disposeKey = self._observers.insert(observer.on)

        if initialCount == 0 {
            let connection = SingleAssignmentDisposable()
            _connection = connection

            connection.setDisposable(self._source.subscribe(self))
        }

        return SubscriptionDisposable(owner: self, key: disposeKey)
    }

    func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        _lock.lock()
        _synchronized_unsubscribe(disposeKey)
        _lock.unlock()
    }

    func _synchronized_unsubscribe(_ disposeKey: DisposeKey) {
        // if already unsubscribed, just return
        if self._observers.removeKey(disposeKey) == nil {
            return
        }

        if _observers.count == 0 {
            _connection?.dispose()
            _connection = nil
        }
    }

    func on(_ event: Event<E>) {
        dispatch(_synchronized_on(event), event)
    }

    func _synchronized_on(_ event: Event<E>) -> Observers {
        _lock.lock(); defer { _lock.unlock() }
        if _stopped {
            return Observers()
        }

        switch event {
        case .next(let element):
            _element = element
            return _observers
        case .error, .completed:
            _stopEvent = event
            _stopped = true
            let observers = _observers
            _observers = Observers()
            _connection?.dispose()
            _connection = nil
            return observers
        }
    }
}
