//
//  VCMapView.swift
//  Map
//
//  Created by Jeremy Kelleher on 7/7/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

import Foundation
import MapKit

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PinnedLocation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.animatesDrop = true
                
                let smallSquare = CGSize(width: 30, height: 30)
                let button = UIButton(frame: CGRect(origin: CGPoint(), size: smallSquare))
                button.backgroundColor = UIColor.blue()
                button.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
                view.leftCalloutAccessoryView = button

                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView // TODO - back to ray for how to handle this
            }
            return view
        }
        return nil
    }
    

    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
}
