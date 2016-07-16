//
//  ViewController.swift
//  Map
//
//  Created by Jeremy Kelleher on 7/7/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

import UIKit
import MapKit
import AddressBook

class ViewController: UIViewController  {
    
    let regionRadius: CLLocationDistance = 1000
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
        
    @IBOutlet weak var map: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        map.delegate = self
        
        // pin drop set up
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addPin))
        map.addGestureRecognizer(gesture)
        
        // location manager setup
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        
        // map user location set up
        map.showsUserLocation = true
        checkLocationAuthorizationStatus()
        
        // search bar setup
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places to pin"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = false // make the map view still usable after the search button is pressed!
        definesPresentationContext = true
        
        locationSearchTable.mapView = map
        
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    // TODO - add button to go to open maps with location
    func addPin(gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: map)
            let newCoordinates = map.convert(touchPoint, toCoordinateFrom: map)
            let annotation = PinnedLocation(title: "Your Location", coordinate: newCoordinates)
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error \(error!.localizedDescription)")
                    return
                }
                
                if let placemarks = placemarks where placemarks.count > 0 {
                    let placemark = placemarks[0]
                    
                    if let name = placemark.name {
                        annotation.title = name
                    }
                    annotation.subtitle = AddressParser.parse(placemark: MKPlacemark(placemark: placemark))
                    
                }
                else {
                    print("Problem with the data received from geocoder")
                }
                self.map.addAnnotation(annotation)
            })
        }
    }
    
}


// MARK: - Handle what happens when a search result is tapped
protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        selectedPin = placemark
        map.removeAnnotations(map.annotations)
        let annotation = PinnedLocation(title: placemark.name, coordinate: placemark.coordinate)
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        map.addAnnotation(annotation)
        centerMapOnLocation(location: placemark.location!)
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
        // store imporant aspects of the table before it's dismissed
        guard let locationSearchTable = resultSearchController?.searchResultsUpdater as? LocationSearchTable else { print("uh oh"); return }
        
        if locationSearchTable.tableViewCompactScreenFrame == nil {
            let shrunkenHeight = locationSearchTable.view.frame.size.height / 3
            locationSearchTable.tableViewCompactScreenFrame = CGRect(x:0.0, y: self.view.bounds.size.height-shrunkenHeight,
                                                 width: self.view.frame.size.width,
                                                 height: shrunkenHeight) // move to bottom of screen
        }
        locationSearchTable.view.frame = locationSearchTable.tableViewCompactScreenFrame!
        
        // for the table view
        locationSearchTable.closeGap()
        
        // FIXME - table view is only moved down (not shrunkin)
        // FIXME - content insets don't move back to normal on taping search bar again (insets?)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        guard let locationSearchTable = resultSearchController?.searchResultsUpdater as? LocationSearchTable else { print("uh oh"); return }
        
        locationSearchTable.view.frame = self.view.frame // this view controllers frame
        locationSearchTable.openGap()
        
        
    }
    
}





