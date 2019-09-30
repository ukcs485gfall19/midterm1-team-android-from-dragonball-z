//
//  ParkMapViewController.swift
//  Midterm_Mapkit
//
//  Created by  on 9/24/19.
//  Copyright © 2019 Team Android. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ParkMapViewController: UIViewController {
    
    var selectedOptions : [MapOptionsType] = []
    var park = Park(filename: "MagicMountain")
    let Manager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationServices()
        
        
        
    }
    
    func locationManager()
    {
        Manager.delegate = self
        
        Manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func locationServices()
    {
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager()
            
            Authorization()
        }
        else
        {
            //check stack overflow for sending a message to the screen
            print("ooh")
        }
    }
    
    func zoom()
    {
          if let userLocation = Manager.location?.coordinate
          {
              let viewregion = MKCoordinateRegionMakeWithDistance(userLocation, 200, 200)
            
              mapView.setRegion(viewregion, animated: true)
          }

    }
    
    func Authorization()
    {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse
        {
            mapView.showsUserLocation = true
            
            if let userLocation = Manager.location?.coordinate
            {
                let viewregion = MKCoordinateRegionMakeWithDistance(userLocation, 200, 200)
                
                mapView.setRegion(viewregion, animated: true)
            }
            
            Manager.startUpdatingLocation()
        }
        else if CLLocationManager.authorizationStatus() == .denied
        {
            // show an allert instruction
            print("ooh")
        }
        else
        {
            Manager.requestWhenInUseAuthorization()
        }
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
                
                case .mapRoute:
                    addRoute()
                
                case .mapBoundary:
                    addBoundary()
                
                case .mapCharacterLocation:
                addCharacterLocation()
                
                // commenting this out because of silly warning
                // default:
                //    break;
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
        
        let notificationMessage = NotificationManager()
        notificationMessage.notifications = [
            NotificationManager.Notification(id: "reminder-1", title: "Remember the milk!", datetime: DateComponents(calendar: Calendar.current, year: 2019, month: 9, day: 29, hour: 16, minute: 47)),
        ]

        notificationMessage.schedule()
    }
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        mapView.mapType = MKMapType.init(rawValue : UInt(sender.selectedSegmentIndex)) ?? .standard
    }
    
    /*func addOverlay()
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

    // reads EntranceToGoliathRoute plist, and converts the coordinates to CLLocationCoordinate2D objecys.
    func addRoute()
    {
        guard let goliathpoints = Park.plist("EntranceToGoliathRoute") as? [String]
        else {
            print("addroute::did not read coords")
            return
        }
        
        let cgPoints = goliathpoints.map {
            CGPointFromString($0)
        }
        
        let coords = cgPoints.map {
            CLLocationCoordinate2DMake(CLLocationDegrees($0.x), CLLocationDegrees($0.y))
        }
        
        let myPolyline = MKPolyline(coordinates: coords, count: coords.count)
        
        print("addroute:: adding polyline: ", myPolyline, " of type :", type(of: myPolyline))
        
        mapView.add(myPolyline)
    }
    
    // given the boundary array and point count from the park instance, create a new MKPolygon
    func addBoundary() {
        mapView.add(MKPolygon(coordinates: park.boundary, count: park.boundary.count))
    }
    
    // passes the plist filename for each ride and a color, then it to the map as an overlay.
    func addCharacterLocation() {
      mapView.add(Character(filename: "BatmanLocations", color: .blue))
      mapView.add(Character(filename: "TazLocations", color: .orange))
      mapView.add(Character(filename: "TweetyBirdLocations", color: .yellow))
    }*/
}

/*extension ParkMapViewController: MKMapViewDelegate
{
    func mapView(_ mapView : MKMapView, rendererFor overlay : MKOverlay) -> MKOverlayRenderer
    {
        print("mapView::overlay renderer:: called")
        if overlay is ParkMapOverlay
        {
            print("mapView::overlay renderer:: returning park map overlay view")
            return ParkMapOverlayView(overlay: overlay, overlayImage: #imageLiteral(resourceName: "overlay_park"))
        }
        else if overlay is MKPolyline // look for mkpolyline objects
        {
            let lineview = MKPolylineRenderer(overlay: overlay)
            lineview.strokeColor = UIColor.green
            
            print("mapView::overlay renderer:: returning line view: ", lineview)
            
            return lineview
        }
        else if overlay is MKPolygon // create an MKOverlayView as a MKPolygonRenderer
        {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = UIColor.magenta
            
            print("mapView::overlay renderer:: returning polygon view: ", polygonView)
            
            return polygonView
        }
        else if let character = overlay as? Character
        {
            let circleView = MKCircleRenderer(overlay: character)
            circleView.strokeColor = character.color
            
            print("mapView::overlay renderer:: returning circle view: ", circleView)
            
            return circleView
        }
        
        print("mapView::overlay renderer:: returning generic mk overlay renderer")
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView : MKMapView, viewFor annotation : MKAnnotation) -> MKAnnotationView?
    {
        print("mapView::annotation view:: called")
        
        let annotationView = AttractionAnnotationView(annotation: annotation, reuseIdentifier: "Attraction")
        
        annotationView.canShowCallout = true
        
        print("mapView::annotation view:: returning", annotationView, " of type: ", type(of: annotationView))
        
        return annotationView
    }

}*/

// core location extension used to update the users location on the map and to check the user authorization permissions
extension ParkMapViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager : CLLocationManager, locationupdate locations : [CLLocation])
    {
        guard let location = locations.last
        else {return}
        
        let center = CLLocationCoordinate2D(latitude:  location.coordinate.latitude, longitude : location.coordinate.longitude)
        
        let viewregion = MKCoordinateRegionMakeWithDistance(center, 200, 200)
        mapView.setRegion(viewregion, animated: true)
        
    }
    
    func locationManager(_ manager : CLLocationManager, authorization : [CLLocation])
    {
        Authorization()
    }
}
