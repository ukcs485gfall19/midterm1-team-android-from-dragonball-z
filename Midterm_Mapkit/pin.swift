//
//  pin.swift
//  Midterm_Mapkit
//
//  Created by  on 10/15/19.
//  Copyright © 2019 Team Android. All rights reserved.
//

import Foundation

class Pin: NSObject
{
    var longitude, lattitude:Float
    var message:String
    var radius:Int
    
    init(longitude:Float, lattitude:Float, message:String, radius:Int) {
        self.longitude = longitude
        self.lattitude = lattitude
        self.message = message
        self.radius = radius
    }
    
    // update pin message / radius / lat,long
    
}
