//
//  PinnedLocation.swift
//  Map
//
//  Created by Jeremy Kelleher on 7/10/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

import Foundation
import MapKit

class PinnedLocation: NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var note: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String? = nil, subtitle: String? = nil, note: String? = nil, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.note = note
        self.coordinate = coordinate
        
        super.init()
    }
    
}
