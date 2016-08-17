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
        
        locationSearchTable.mapView = map
        locationSearchTable.handleMapSearchDelegate = self
        
        let searchBar = resultSearchController!.searchBar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places to pin"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = false // make the map view still usable after the search button is pressed!
        definesPresentationContext = true
        
        // map buttons
        
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
        searchedPins.removeAll()
        self.savePinsHoverBar.isHidden = true
    }
    
}


// MARK: - Handle what happens when a search result is tapped
protocol HandleMapSearch {
    func dropPin(for placemark:MKPlacemark, saveToLocations save: Bool)
}

extension ViewController: HandleMapSearch {
    func dropPin(for placemark:MKPlacemark, saveToLocations save: Bool = true) {
        
        // if the pin is not present, add it
        var annotation: Pinnable
        if save {
            annotation = PinnedLocation(title: placemark.name, coordinate: placemark.coordinate)
            locations.append(annotation as! PinnedLocation)
            centerMapOnLocation(location: placemark.location!)
        } else {
            annotation = SearchedLocation(title: placemark.name, coordinate: placemark.coordinate)
            searchedPins.append(annotation as! SearchedLocation)
        }
        
        annotation.placemark = placemark
        annotation.subtitle = AddressParser.parse(placemark: placemark)
        map.addAnnotation(annotation)
    
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
        map.setRegion(region, animated: true)
    }
    
    func clearMapOfSearches() {
        map.removeAnnotations(searchedPins)
        searchedPins = []
        savePinsHoverBar.isHidden = true
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
        guard let locationSearchTable = resultSearchController?.searchResultsUpdater as? LocationSearchTable else { print("location table not present after search button pressed"); return }
        
        // only drop pins for the addresses (don't include the suggested topics)
        let addresses = locationSearchTable.matchingItems.filter { return $0.subtitle != "" }
        for address in addresses {
            let searchRequest = MKLocalSearchRequest(completion: address)
            let search = MKLocalSearch(request: searchRequest)
            search.start { (response, error) in
                if let placemark = response?.mapItems[0].placemark {
                    self.dropPin(for: placemark, saveToLocations: false)
                }
                if address == addresses.last {
                    self.fitMapRegionForSearchedPins()
                }
            }
        }
        
        self.savePinsHoverBar.isHidden = false
        locationSearchTable.dismiss(animated: true)
    }

    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clearMapOfSearches()
    }
}





