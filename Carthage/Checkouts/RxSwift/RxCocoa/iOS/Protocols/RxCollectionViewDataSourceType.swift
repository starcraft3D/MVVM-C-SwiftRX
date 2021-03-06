//
//  RxCollectionViewDataSourceType.swift
//  RxCocoa
//
//  Created by PowerMobile Team on 6/29/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

/// Marks data source as `UICollectionView` reactive data source enabling it to be used with one of the `bindTo` methods.
public protocol RxCollectionViewDataSourceType /*: UICollectionViewDataSource*/ {
    
    /// Type of elements that can be bound to collection view.
    associatedtype Element
    
    /// New observable sequence event observed.
    ///
    /// - parameter collectionView: Bound collection view.
    /// - parameter observedEvent: Event
    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) -> Void
}

#endif
