//
//  MapViewController.swift
//  Midterm_Mapkit
//
//  Created by  on 9/24/19.
//  Copyright © 2019 Team Android. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    var selectedOptions : [MapOptionsType] = []
    
    var longitude: String = ""
    var latitude: String = ""
    let Manager = CLLocationManager()
    @IBOutlet var mapView: MKMapView!
    
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
        addPin()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? MapOptionsViewController)?.selectedOptions = selectedOptions
    }
    
    @IBAction func closeOptions(_ exitSegue: UIStoryboardSegue) {
        guard let vc = exitSegue.source as? MapOptionsViewController else { return }
        selectedOptions = vc.selectedOptions
        latitude = vc.latitude.text ?? ""
        longitude = vc.longitude.text ?? ""
        loadSelectedOptions()
        
        let notificationMessage = NotificationManager()
        notificationMessage.notifications = [
            NotificationManager.Notification(id: "reminder-1", title: "Remember the milk!", datetime: DateComponents(calendar: Calendar.current, year: 2019, month: 9, day: 30, hour: 18, minute: 10)),
        ]

        notificationMessage.schedule()
    }
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        mapView.mapType = MKMapType.init(rawValue : UInt(sender.selectedSegmentIndex)) ?? .standard
    }
    
    func addPin() {
        if longitude == latitude && longitude == "" {}
        else if longitude != "" && latitude != ""
        {
            let lat = (latitude as NSString).doubleValue
            let lon = (longitude as NSString).doubleValue
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            let annotation = MKPointAnnotation()
            print(coordinate)
            annotation.title = "Example Pin"
            annotation.subtitle = "Subtitle"
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            print(mapView)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
}

// core location extension used to update the users location on the map and to check the user authorization permissions
extension MapViewController: CLLocationManagerDelegate
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
