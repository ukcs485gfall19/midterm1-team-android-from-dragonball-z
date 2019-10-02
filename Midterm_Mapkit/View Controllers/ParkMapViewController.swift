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
    
    var selectedOptions : [MapOptionsTypeTut] = []
    var park = Park(filename: "MagicMountain")
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Total distance of the latitude span, used to generate full view.
        let latDelta = park.overlayTopLeftCoordinate.latitude -
            park.overlayBottomRightCoordinate.latitude
        
        // Span defines the size of the screen, based on the latitude delta.
        let span = MKCoordinateSpanMake(fabs(latDelta), 0.0)
        // Region defines the span around a point at the center of the park
        let region = MKCoordinateRegionMake(park.midCoordinate, span)
        
        //Set the mapView region to the region calculated, forces zoom into the park.
        mapView.region = region
    }
    
    func loadSelectedOptions()
    {
        // Remove annotations and overlays
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        // Place annotations and overlays based on which options are selected in the selectedOptions.
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
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Link the selectedOptions from the MapOptionsViewController (for the tutorial) to the selectedOptions variable in this controller.
        (segue.destination as? MapOptionsViewControllerTutorial)?.selectedOptions = selectedOptions
    }
    
    @IBAction func closeOptions(_ exitSegue: UIStoryboardSegue) {
        // Get the selectedOptions from the MapOptionsViewController (for the tutorial) when the exit segue is performed.
        guard let vc = exitSegue.source as? MapOptionsViewControllerTutorial else { return }
        selectedOptions = vc.selectedOptions
        
        //Automatically calls the functions to overlay what is selected.
        loadSelectedOptions()
    }
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        mapView.mapType = MKMapType.init(rawValue : UInt(sender.selectedSegmentIndex)) ?? .standard
    }
    
    func addOverlay()
    {
        // Use the ParkMapOverlay we defined to generate an overlay to the park and add it to the mapView.
        let overlay = ParkMapOverlay(park: park)
        mapView.add(overlay)
    }
    
    func addAttractionPins()
    {
        // Get pin data from the plist
        guard let attractions = Park.plist("MagicMountainAttractions") as? [[String : String]] else { return }
        
        // For each pin in the plist, create an annotation
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
        // Read the plist
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
        
        // Generate a line based on the coordinates given.
        let myPolyline = MKPolyline(coordinates: coords, count: coords.count)
        
        print("addroute:: adding polyline: ", myPolyline, " of type :", type(of: myPolyline))
        
        // Add the path line to the map.
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
    // Generate a renderer that displays overlays in a specific way. Blocks other overlays from being rendered.
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
    
    // create a renderer for the annotations created.
    func mapView(_ mapView : MKMapView, viewFor annotation : MKAnnotation) -> MKAnnotationView?
    {
        print("mapView::annotation view:: called")
        
        let annotationView = AttractionAnnotationView(annotation: annotation, reuseIdentifier: "Attraction")
        
        annotationView.canShowCallout = true
        
        print("mapView::annotation view:: returning", annotationView, " of type: ", type(of: annotationView))
        
        return annotationView
    }
    
    // Attempt to allow unwinding to main storyboard.
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {

    }

    // Attempt to rewind to the main storyboard.
    @IBAction func closeTutorial(_ exitSegue: UIStoryboardSegue) {
        self.performSegue(withIdentifier: "unwindToMain", sender: self)
    }

}

