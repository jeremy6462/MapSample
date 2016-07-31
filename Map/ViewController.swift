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
    
    var resultSearchController: UISearchController? = nil
    var selectedPin: Pinnable? = nil
    
    var locations: [PinnedLocation] = []
    var searchedPins: [SearchedLocation] = []
        
    @IBOutlet weak var currentLocationHoverBar: ISHHoverBar!
    @IBOutlet weak var savePinsHoverBar: ISHHoverBar!
    
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
        
        // current location hover bar
        let mapBarButton = MKUserTrackingBarButtonItem(mapView: map)
        self.currentLocationHoverBar.items = [mapBarButton]
        
        // save pins hover bar
        let savePinsButton = UIButton(type: .contactAdd)
        savePinsButton.tintColor = UIColor.green()
        savePinsButton.frame = savePinsHoverBar.frame
        savePinsButton.addTarget(self, action: #selector(savePins), for: .touchUpInside)
        let savePinsBarButton = UIBarButtonItem(customView: savePinsButton)
        savePinsHoverBar.items = [savePinsBarButton]
        savePinsHoverBar.isHidden = true
    }
    
    // TODO - add button to go to open maps with location
    func addPin(gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: map)
            let newCoordinates = map.convert(touchPoint, toCoordinateFrom: map)
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    if error?.code == 2 {
                        print("not good enough internet connection to get the address of you pin")
                    }
                    else {
                        print("Reverse geocoder failed with error \(error!.localizedDescription)")
                    }
                    return
                }
                
                if let placemarks = placemarks where placemarks.count > 0 {
                    let placemark = placemarks[0]
                    
                    let annotation = PinnedLocation(title: placemark.name, coordinate: newCoordinates)
                    annotation.placemark = MKPlacemark(placemark: placemark)
                    annotation.subtitle = AddressParser.parse(placemark: MKPlacemark(placemark: placemark))
                    self.map.addAnnotation(annotation)
                    self.locations.append(annotation)
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
    }
    
    func savePins() {
        for searchedPin in searchedPins {
            let pin = PinnedLocation(title: searchedPin.title!, subtitle: searchedPin.subtitle!, coordinate: searchedPin.coordinate)
            map.removeAnnotation(searchedPin)
            map.addAnnotation(pin)
            self.locations.append(pin)
        }
        self.savePinsHoverBar.isHidden = true
    }
    
}


// MARK: - Handle what happens when a search result is tapped
protocol HandleMapSearch {
    func dropPinnedLocationZoomIn(placemark:MKPlacemark)
    func dropSearchedLocation(placemark:MKPlacemark)
}

extension ViewController: HandleMapSearch {
    func dropPinnedLocationZoomIn(placemark:MKPlacemark) {
        let annotation = PinnedLocation(title: placemark.name, coordinate: placemark.coordinate)
        annotation.placemark = placemark
        annotation.subtitle = AddressParser.parse(placemark: placemark)
        
        map.addAnnotation(annotation)
        locations.append(annotation)
        centerMapOnLocation(location: placemark.location!)
    }
    
    func dropSearchedLocation(placemark:MKPlacemark) {
        let annotation = SearchedLocation(title: placemark.name, coordinate: placemark.coordinate)
        annotation.placemark = placemark
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        map.addAnnotation(annotation)
        self.searchedPins.append(annotation)

    }
    
    func fitMapRegionForSearchedPins() {
        var upper = searchedPins[0].coordinate
        var lower = searchedPins[0].coordinate
        for pin in searchedPins {
            if pin.coordinate.latitude > upper.latitude { upper.latitude = pin.coordinate.latitude }
            if pin.coordinate.latitude < lower.latitude { lower.latitude = pin.coordinate.latitude }
            if pin.coordinate.longitude > upper.longitude { upper.longitude = pin.coordinate.longitude }
            if pin.coordinate.longitude < lower.longitude { lower.longitude = pin.coordinate.longitude }
        }
        
        let locationSpan = MKCoordinateSpan(latitudeDelta: upper.latitude - lower.latitude, longitudeDelta: upper.longitude - lower.longitude)
        let locationCenter = CLLocationCoordinate2D(latitude: (upper.latitude + lower.latitude) / 2, longitude: (upper.longitude + lower.longitude) / 2)
        
        let region = MKCoordinateRegionMake(locationCenter, locationSpan)
        map.region = region
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
        guard let locationSearchTable = resultSearchController?.searchResultsUpdater as? LocationSearchTable else { print("location table not present after search button pressed"); return }
        
        locationSearchTable.shrink()
        
        for searchedLocation in locationSearchTable.matchingItems {
            let placemark = searchedLocation.placemark
            dropSearchedLocation(placemark: placemark)
        }
        
        self.savePinsHoverBar.isHidden = false
        
        fitMapRegionForSearchedPins()
        
        // FIXME - table view is only moved down (not shrunkin)
        // FIXME - content insets don't move back to normal on taping search bar again (insets?)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        guard let locationSearchTable = resultSearchController?.searchResultsUpdater as? LocationSearchTable else { print("location table not present after search text field tapped"); return }
        
        locationSearchTable.view.frame = self.view.frame // this view controllers frame
        locationSearchTable.grow();
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.map.removeAnnotations(searchedPins)
        self.savePinsHoverBar.isHidden = true
        
    }
    
}





