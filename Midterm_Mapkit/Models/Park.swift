//
//  Park.swift
//  Midterm_Mapkit
//
//  Created by   on 9/26/19.
//  Copyright © 2019 Team Android. All rights reserved.
//

import UIKit
import MapKit

class Park {
    var name: String?
    var boundary: [CLLocationCoordinate2D] = []
    
    // Coordinates for the differnt points on the overlay
    var midCoordinate = CLLocationCoordinate2D()
    var overlayTopLeftCoordinate = CLLocationCoordinate2D()
    var overlayTopRightCoordinate = CLLocationCoordinate2D()
    var overlayBottomLeftCoordinate = CLLocationCoordinate2D()
    var overlayBottomRightCoordinate: CLLocationCoordinate2D {
        // Because the overlay is a rectangle, the bottom right coordinate can be calculated by taking the bottom left y value (latitude) with the top right x value (longitude).
        get {
            return CLLocationCoordinate2DMake(overlayBottomLeftCoordinate.latitude,
                                              overlayTopRightCoordinate.longitude)
        }
    }
    var overlayBoundingMapRect: MKMapRect {
        get {
            // Get the needed coordinates.
            let topLeft = MKMapPointForCoordinate(overlayTopLeftCoordinate)
            let topRight = MKMapPointForCoordinate(overlayTopRightCoordinate)
            let bottomLeft = MKMapPointForCoordinate(overlayBottomLeftCoordinate)
            
            //Create the rectangle that bounds the view.
            return MKMapRectMake(
                topLeft.x,
                topLeft.y,
                fabs(topLeft.x - topRight.x),
                fabs(topLeft.y - bottomLeft.y))
        }
    }
    class func plist(_ plist: String) -> Any? {
        // a function to easily load plist data. Takes the plist name and attempts to open it from object files. Returns the data.
        let filePath = Bundle.main.path(forResource: plist, ofType: "plist")!
        let data = FileManager.default.contents(atPath: filePath)!
        return try! PropertyListSerialization.propertyList(from: data, options: [], format: nil)
    }

    static func parseCoord(dict: [String: Any], fieldName: String) -> CLLocationCoordinate2D {
        // Parse the data from the plist and create coordinates based on that set of data.
        guard let coord = dict[fieldName] as? String else {
            return CLLocationCoordinate2D()
        }
        let point = CGPointFromString(coord)
        return CLLocationCoordinate2DMake(CLLocationDegrees(point.x), CLLocationDegrees(point.y))
    }
    
    init(filename: String) {
        // Get the propeties and boundary from the park plist
        guard let properties = Park.plist(filename) as? [String : Any],
            let boundaryPoints = properties["boundary"] as? [String] else { return }
        
        // Generate the overlay coordinates based on the data found in the plist using the parseCoord function above.
        midCoordinate = Park.parseCoord(dict: properties, fieldName: "midCoord")
        overlayTopLeftCoordinate = Park.parseCoord(dict: properties, fieldName: "overlayTopLeftCoord")
        overlayTopRightCoordinate = Park.parseCoord(dict: properties, fieldName: "overlayTopRightCoord")
        overlayBottomLeftCoordinate = Park.parseCoord(dict: properties, fieldName: "overlayBottomLeftCoord")
        
        // generate the map boundary coordinates for use in the ParkMapViewController.
        let cgPoints = boundaryPoints.map { CGPointFromString($0) }
        boundary = cgPoints.map { CLLocationCoordinate2DMake(CLLocationDegrees($0.x), CLLocationDegrees($0.y)) }
    }
    
    
}
