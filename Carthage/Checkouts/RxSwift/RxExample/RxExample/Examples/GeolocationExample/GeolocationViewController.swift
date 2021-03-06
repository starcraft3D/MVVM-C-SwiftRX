//
//  GeolocationViewController.swift
//  RxExample
//
//  Created by Carlos García on 19/01/16.
//  Copyright © 2016 PowerMobile Team. All rights reserved.
//

import UIKit
import CoreLocation
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

private extension Reactive where Base: UILabel {
    var coordinates: UIBindingObserver<Base, CLLocationCoordinate2D> {
        return UIBindingObserver(UIElement: base) { label, location in
            label.text = "Lat: \(location.latitude)\nLon: \(location.longitude)"
        }
    }
}

class GeolocationViewController: ViewController {
    
    @IBOutlet weak private var noGeolocationView: UIView!
    @IBOutlet weak private var button: UIButton!
    @IBOutlet weak private var button2: UIButton!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(noGeolocationView)
        
        let geolocationService = GeolocationService.instance
        
        geolocationService.authorized
            .drive(noGeolocationView.rx.isHidden)
            .disposed(by: disposeBag)
        
        geolocationService.location
            .drive(label.rx.coordinates)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .bind { [weak self] in
                self?.openAppPreferences()
            }
            .disposed(by: disposeBag)
        
        button2.rx.tap
            .bind { [weak self] in
                self?.openAppPreferences()
            }
            .disposed(by: disposeBag)
    }
    
    private func openAppPreferences() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    
}
