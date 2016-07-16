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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shrunkenHeight = self.view.frame.size.height / 3
        tableViewCompactScreenFrame = CGRect(x:0.0, y: self.view.bounds.size.height-shrunkenHeight,
                           width: self.view.frame.size.width,
                           height: shrunkenHeight) // move to bottom of screen
    }
    
    func closeGap() {
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func openGap() {
        self.tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        self.automaticallyAdjustsScrollViewInsets = true
    }
    
}

extension LocationSearchTable : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView, let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
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
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil) // TODO - shrink to bottom, not dismiss
    }

}
