//
//  GeolocationService.swift
//  RxExample
//
//  Created by Carlos García on 19/01/16.
//  Copyright © 2016 PowerMobile Team. All rights reserved.
//

import CoreLocation
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class GeolocationService {
    
    static let instance = GeolocationService()
    private (set) var authorized: Driver<Bool>
    private (set) var location: Driver<CLLocationCoordinate2D>
    
    private let locationManager = CLLocationManager()
    
    private init() {
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        authorized = Observable.deferred { [weak locationManager] in
                let status = CLLocationManager.authorizationStatus()
                guard let locationManager = locationManager else {
                    return Observable.just(status)
                }
                return locationManager
                    .rx.didChangeAuthorizationStatus
                    .startWith(status)
            }
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
            .map {
                switch $0 {
                case .authorizedAlways:
                    return true
                default:
                    return false
                }
            }
        
        location = locationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .flatMap {
                return $0.last.map(Driver.just) ?? Driver.empty()
            }
            .map { $0.coordinate }
        
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}
