//
//  LocationSearchTable.swift
//  Map
//
//  Created by Jeremy Kelleher on 7/13/16.
//  Copyright © 2016 JKProductions. All rights reserved.
//

import UIKit
import MapKit
import ISHPullUp

class LocationSearchTable : UITableViewController {
    
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    var tableViewCompactScreenFrame: CGRect?
    
    enum State: Int {
        case compact
        case fullScreen
    }
    
    var state: State = .fullScreen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        state = .fullScreen
        
        let shrunkenHeight = self.view.frame.size.height / 3
        tableViewCompactScreenFrame = CGRect(x:0.0, y: self.view.bounds.size.height-shrunkenHeight,
                           width: self.view.frame.size.width,
                           height: shrunkenHeight)
    }
    
    func shrink() {
        if self.tableViewCompactScreenFrame == nil {
            let shrunkenHeight = self.view.frame.size.height / 3
            self.tableViewCompactScreenFrame = CGRect(x:0.0, y: self.view.bounds.size.height-shrunkenHeight, width: self.view.frame.size.width, height: shrunkenHeight)
        }
        if state == .fullScreen {
            self.view.frame = self.tableViewCompactScreenFrame!
//            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            state = .compact
        }
    }
    
    func grow() {
        if state == .compact {
            self.view.frame = CGRect(x:0.0, y: self.view.frame.size.height * 3, width: self.view.frame.size.width, height: self.view.frame.size.height * 3)
//            self.tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
//            self.automaticallyAdjustsScrollViewInsets = true
            state = .fullScreen
        }
    }
    
}

extension LocationSearchTable : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView, let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        // FIXME - bad search results (eg. Panera)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
}


// MARK: - Table View methods
extension LocationSearchTable {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = AddressParser.parse(placemark: selectedItem)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinnedLocationZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }

}
