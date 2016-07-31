//
//  PinnedLocation.swift
//  Map
//
//  Created by Jeremy Kelleher on 7/10/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

import Foundation
import MapKit

class PinnedLocation: NSObject, Pinnable {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var placemark: MKPlacemark?
    var pinColor: UIColor = UIColor.green()
    
    init(title: String? = nil, subtitle: String? = nil, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        super.init()
    }
}

class SearchedLocation: NSObject, Pinnable {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var placemark: MKPlacemark?
    var pinColor: UIColor = UIColor.red()

    
    init(title: String? = nil, subtitle: String? = nil, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        super.init()
    }
}

protocol Pinnable: MKAnnotation {
    var title: String? { get set }
    var subtitle: String? { get set }
    var coordinate: CLLocationCoordinate2D { get set }
    var placemark: MKPlacemark? { get set }
    var pinColor: UIColor { get }
}



