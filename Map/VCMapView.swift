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
    
    // TODO - different MKAnnotations for pinned location and searched location
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Pinnable { // FIXME
            let identifier = "pin"
            var view: MKPinAnnotationView
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.animatesDrop = true
            view.isDraggable = true
            view.pinTintColor = annotation.pinColor
            
            // directions button
            let smallSquare = CGSize(width: 50, height: 50)
            let directions = UIButton(frame: CGRect(origin: CGPoint(), size: smallSquare))
            directions.backgroundColor = UIColor.blue()
            directions.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
            view.leftCalloutAccessoryView = directions
            
            // add/remove from location list
            var imageName: String
            if annotation is PinnedLocation {
                imageName = "removeLocation"
            } else { // it's a searched pin
                imageName = "addLocation"
            }
            let button = UIButton(type: .detailDisclosure)
            button.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal), for: .normal)
            view.rightCalloutAccessoryView = button
            view.canShowCallout = true
            
            return view
        }
        return nil
    }
    

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedPin = view.annotation as? Pinnable
    }
    
    func getDirections() {
        if let selectedPin = selectedPin, let placemark = selectedPin.placemark {
            let mapItem = MKMapItem(placemark: placemark)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    // MARK - Accessory Button
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let selectedPin = selectedPin {
            if selectedPin is PinnedLocation {
                removeLocation()
            } else {
                addLocation()
            }
        }
    }
    
    func addLocation() {
        if let selectedPin = selectedPin {
            let pin = PinnedLocation(title: selectedPin.title!, subtitle: selectedPin.subtitle!, coordinate: selectedPin.coordinate)
            removeLocation()
            locations.append(pin)
            self.map.addAnnotation(pin)
        }
    }
    
    func removeLocation() {
        if let selectedPin = selectedPin {
            self.map.removeAnnotation(selectedPin)
            locations = locations.filter() { $0.title != selectedPin.title }
            // FIXME - PinnedLocations should be comparable
        }
    }

    
}
