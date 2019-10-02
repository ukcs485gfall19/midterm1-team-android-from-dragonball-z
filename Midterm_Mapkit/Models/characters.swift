//
//  characters.swift
//  Midterm_Mapkit
//
//  Created by  on 9/29/19.
//  Copyright © 2019 Team Android. All rights reserved.
//

import UIKit
import MapKit

// character class defines name and color as optional properties.
class Character: MKCircle
{
    var name: String?
    var color: UIColor?
    
    // convenience initializer accepts a plist filename and color to draw the circle
    convenience init(filename: String, color: UIColor)
    {
        // Then it reads in the data from the plist file
        guard let points = Park.plist(filename) as? [String] else
        {
            self.init()
            return
        }
        // selects a random location from the four locations in the file
        let cgPoints = points.map {
            CGPointFromString($0)
        }
        
        let coords = cgPoints.map {
            CLLocationCoordinate2DMake(CLLocationDegrees($0.x), CLLocationDegrees($0.y))
        }
        
        //chooses a random radius to simulate time variance
        let randomCenter = coords[Int(arc4random()%4)]
        let randomRadius = CLLocationDistance(max(5, Int(arc4random()%40)))
        
        self.init(center: randomCenter, radius: randomRadius)
        
        self.name = filename
        self.color = color
    }
}
