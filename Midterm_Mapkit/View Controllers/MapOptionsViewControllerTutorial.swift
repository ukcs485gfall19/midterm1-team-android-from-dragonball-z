//
//  MapOptionsViewController.swift
//  Midterm_Mapkit
//
//  Created by   on 9/26/19.
//  Copyright © 2019 Team Android. All rights reserved.
//

import UIKit

enum MapOptionsTypeTut: Int {
  case mapBoundary = 0
  case mapOverlay
  case mapPins
  case mapCharacterLocation
  case mapRoute
  
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

class MapOptionsViewControllerTutorial: UIViewController {
  
  var selectedOptions = [MapOptionsTypeTut]()
}

// MARK: - UITableViewDataSource
extension MapOptionsViewControllerTutorial: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell")!
    
    if let mapOptionsType = MapOptionsTypeTut(rawValue: indexPath.row) {
      cell.textLabel!.text = mapOptionsType.displayName()
      cell.accessoryType = selectedOptions.contains(mapOptionsType) ? .checkmark : .none
    }
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension MapOptionsViewControllerTutorial: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    guard let mapOptionsType = MapOptionsTypeTut(rawValue: indexPath.row) else { return }
    
    if (cell.accessoryType == .checkmark) {
      // Remove option
      selectedOptions = selectedOptions.filter { $0 != mapOptionsType}
      cell.accessoryType = .none
    } else {
      // Add option
      selectedOptions += [mapOptionsType]
      cell.accessoryType = .checkmark
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
