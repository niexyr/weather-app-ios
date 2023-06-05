//
//  LocationServiceDelegate.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa
import UIKit

protocol LocationServiceDelegate: AnyObject {
    
    func handleNoAccess()
    
}

class LocationService: NSObject {
    
    let currentUserLocation = PublishSubject<CLLocation?>()
    
    private let locationManager = CLLocationManager()
    weak var delegate: LocationServiceDelegate?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        requestAccess(with: locationManager)
    }
    
    private func requestAccess(with manager: CLLocationManager) {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            delegate?.handleNoAccess()
            currentUserLocation.onNext(nil)
            
        default:
            print("Unknown status")
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            currentUserLocation.onNext(nil)
            return
        }
        
        let location = lastLocation as CLLocation
        currentUserLocation.onNext(location)
        manager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestAccess(with: manager)
    }
    
}
