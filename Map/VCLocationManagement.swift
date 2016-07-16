//
//  VCLocationManagement.swift
//  Map
//
//  Created by Jeremy Kelleher on 7/10/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

import UIKit
import MapKit

extension ViewController: CLLocationManagerDelegate {
    
    
    func checkLocationAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            centerMapOnLocation(location: CLLocation(latitude: 21.283921, longitude: -157.831661))
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            centerMapOnLocation(location: CLLocation(latitude: 21.283921, longitude: -157.831661))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: NSError) {
        if CLLocationManager.authorizationStatus() == .denied {
            print("User has denied location services");
        } else {
            print("Location manager did fail with error: \(error.localizedFailureReason)")
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        centerMapOnLocation(location: currentLocation!)
    }
}
