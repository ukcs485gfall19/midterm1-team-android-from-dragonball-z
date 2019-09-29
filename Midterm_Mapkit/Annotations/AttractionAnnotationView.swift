//
//  File.swift
//  Midterm_Mapkit
//
//  Created by Nicholas Poe on 9/26/19.
//  Copyright © 2019 Team Android. All rights reserved.
//

import UIKit
import MapKit

class AttractionAnnotationView : MKAnnotationView
{
  required init?(coder aDecoder : NSCoder)
  {
    super.init(coder : aDecoder)
  }
  
  override init(annotation : MKAnnotation?, reuseIdentifier : String?)
  {
    super.init(annotation : annotation, reuseIdentifier : reuseIdentifier)
    
    guard let attractionAnnotation = self.annotation as? AttractionAnnotation else { return }
    
    image = attractionAnnotation.type.image()
  }
}

