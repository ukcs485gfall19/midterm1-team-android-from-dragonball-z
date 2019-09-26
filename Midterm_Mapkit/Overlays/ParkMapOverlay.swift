//
//  File.swift
//  Midterm_Mapkit
//
//  Created by Nicholas Poe on 9/26/19.
//  Copyright © 2019 Team Android. All rights reserved.
//

import UIKit
import MapKit

class ParkMapOverlay : NSObject, MKOverlay
{
  var coordinate : CLLocationCoordinate2D
  var boundingMapRect : MKMapRect

  init(park: Park)
  {
    boundingMapRect = park.overlayBoundingMapRect
    
    coordinate = park.midCoordinate
  }
}

