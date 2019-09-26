//
//  ParkMapViewController.swift
//  Midterm_Mapkit
//
//  Created by  on 9/24/19.
//  Copyright © 2019 Team Android. All rights reserved.
//

import UIKit
import MapKit

class ParkMapViewController: UIViewController {
    
    var selectedOptions : [MapOptionsType] = []
    var park = Park(filename: "MagicMountain")
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let latDelta = park.overlayTopLeftCoordinate.latitude -
            park.overlayBottomRightCoordinate.latitude
        
        // Think of a span as a tv size, measure from one corner to another
        let span = MKCoordinateSpanMake(fabs(latDelta), 0.0)
        let region = MKCoordinateRegionMake(park.midCoordinate, span)
        
        mapView.region = region
    }
    
    func loadSelectedOptions()
    {
        mapView.removeAnnotations(mapView.annotations)
        
        mapView.removeOverlays(mapView.overlays)
        
        for option in selectedOptions
        {
            switch (option)
            {
                case .mapOverlay:
                    addOverlay()
                
                case .mapPins:
                    addAttractionPins()
                
                default:
                    break;
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? MapOptionsViewController)?.selectedOptions = selectedOptions
    }
    
    @IBAction func closeOptions(_ exitSegue: UIStoryboardSegue) {
        guard let vc = exitSegue.source as? MapOptionsViewController else { return }
        selectedOptions = vc.selectedOptions
        loadSelectedOptions()
    }
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        
        mapView.mapType = MKMapType.init(rawValue : UInt(sender.selectedSegmentIndex)) ?? .standard

    }
    
    func addOverlay()
    {
      let overlay = ParkMapOverlay(park: park)
        
      mapView.add(overlay)
        
    }
    
    func addAttractionPins()
    {
      guard let attractions = Park.plist("MagicMountainAttractions") as? [[String : String]] else { return }
        
      for attraction in attractions
      {
        let coordinate = Park.parseCoord(dict: attraction, fieldName: "location")
        let title = attraction["name"] ?? ""
        
        let typeRawValue = Int(attraction["type"] ?? "0") ?? 0
        
        let type = AttractionType(rawValue: typeRawValue) ?? .misc
        
        let subtitle = attraction["subtitle"] ?? ""
        
        let annotation = AttractionAnnotation(coordinate: coordinate, title : title, subtitle : subtitle, type: type)
        
        mapView.addAnnotation(annotation)
      }
    }

}

extension ParkMapViewController: MKMapViewDelegate
{
    func mapView(_ mapView : MKMapView, rendererFor overlay : MKOverlay) -> MKOverlayRenderer
    {
      if overlay is ParkMapOverlay
      {
        return ParkMapOverlayView(overlay : overlay, overlayImage : #imageLiteral(resourceName: "overlay_park"))
      }
      
      return MKOverlayRenderer()
    }
    
    func mapView(_ mapView : MKMapView, viewFor annotation : MKAnnotation) -> MKAnnotationView?
    {
      let annotationView = AttractionAnnotationView(annotation: annotation, reuseIdentifier: "Attraction")
        
      annotationView.canShowCallout = true
        
      return annotationView
    }

}

