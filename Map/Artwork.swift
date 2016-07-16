//
//  Artwork.swift
//  Map
//
//  Created by Jeremy Kelleher on 7/7/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

import Foundation
import MapKit

class PinnedLocation: NSObject, MKAnnotation {
    
    let title: String?
    var note: String?
    let coordinate: CLLocationCoordinate2D
    var subtitle: String? {
        return title
    }

    
    init(title: String, note: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.note = note
        self.coordinate = coordinate
        
        super.init()
    }
    
    }
