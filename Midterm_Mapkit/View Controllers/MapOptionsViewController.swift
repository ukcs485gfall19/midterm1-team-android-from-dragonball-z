//
//  MapOptionsViewController.swift
//  Midterm_Mapkit
//
//  Created by   on 9/26/19.
//  Copyright © 2019 Team Android. All rights reserved.
//

import UIKit

enum MapOptionsType: Int {
    // Generate an enumerated list with the different map options to be displayed
    case mapBoundary = 0
    case mapOverlay
    case mapPins
    case mapCharacterLocation
    case mapRoute
    
    // Set the viewable map options to the enumerated list.
    func displayName() -> String {
        switch (self) {
        case .mapBoundary:
            return "Park Boundary"
        case .mapOverlay:
            return "Map Overlay"
        case .mapPins:
            return "Attraction Pins"
        case .mapCharacterLocation:
            return "Character Location"
        case .mapRoute:
            return "Route"
        }
    }
}

class MapOptionsViewController: UIViewController {
    // Set the viewable map options to the enumerated list.
    var selectedOptions = [MapOptionsType]()
    
    // Add latitude and longitude fields for use
    @IBOutlet var longitude: UITextField!
    @IBOutlet var latitude: UITextField!

}

extension MapOptionsViewController: UITableViewDataSource {
  
    // Return the number of sections in the view (only 1)
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Return the number of options in the section (the 5 options from the enumeration)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // set cell to be the section of the table where the options are displayed, has identifier OptionCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell")!
        
        // For each of the map options, create a display in the cell that is not checked by default.
        if let mapOptionsType = MapOptionsType(rawValue: indexPath.row) {
            cell.textLabel!.text = mapOptionsType.displayName()
            cell.accessoryType = selectedOptions.contains(mapOptionsType) ? .checkmark : .none
        }
        
        // Return the list of options
        return cell
    }
}
