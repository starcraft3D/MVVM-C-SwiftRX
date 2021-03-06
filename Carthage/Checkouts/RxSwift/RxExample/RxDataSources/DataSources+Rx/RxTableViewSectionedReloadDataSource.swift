//
//  RxTableViewSectionedReloadDataSource.swift
//  RxExample
//
//  Created by PowerMobile Team on 6/27/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

open class RxTableViewSectionedReloadDataSource<S: SectionModelType>
    : TableViewSectionedDataSource<S>
    , RxTableViewDataSourceType {
    public typealias Element = [S]

    public override init() {
        super.init()
    }

    open func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { dataSource, element in
            #if DEBUG
                self._dataSourceBound = true
            #endif
            dataSource.setSections(element)
            tableView.reloadData()
        }.on(observedEvent)
    }
}
