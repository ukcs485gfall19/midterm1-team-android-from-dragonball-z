//
//  ParkMapViewController.swift
//  Midterm_Mapkit
//
//  Created by  on 9/24/19.
//  Copyright © 2019 Team Android. All rights reserved.
//

import UIKit
import MapKit
//import UserNotifications

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
        
        /* old tutorial code
        // get the notification center
        let center = UNUserNotificationCenter.current()
        
        // edit the notification by setting up its properties
        let content = UNMutableNotificationContent()
        
        // notification message
        content.title = "notificaiton title"
        content.subtitle = "notification subtitle"
        content.body = "this is the body"
        
        // change notificaiton sound
        content.sound = UNNotificationSound.default()
        
        // make sure this app's notifications go into the correct group
        content.threadIdentifier = "local-notification"
        
        let date = Date(timeIntervalSinceNow: 10)
        
        // create a date component from the date
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        // create a trigger based on the calendar components we just set up
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // combine the content we just set up with the trigger we just made
        let request = UNNotificationRequest(identifier: "content", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if error != nil {
                print(error)
            }
        }
         */
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
    }
}

extension ParkMapViewController: MKMapViewDelegate
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

}

