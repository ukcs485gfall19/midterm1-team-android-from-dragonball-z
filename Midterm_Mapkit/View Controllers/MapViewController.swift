//
//  MapViewController.swift
//  Midterm_Mapkit
//
//  Created by  on 9/24/19.
//  Copyright © 2019 Team Android. All rights reserved.
//
// For core location, the tutorial at https://www.youtuve.com/watch?v=WPpaAy73nJc was used
// For pin rendering and the page https://forums.developer.apple.com/thread/121665 was used


import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    // Define the variables used in the controller
    var selectedOptions : [MapOptionsType] = []
    
    var longitude: String = ""
    var latitude: String = ""
    let Manager = CLLocationManager()
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Begin location services.
        locationServices()
    }
    
    // Instantiates the desired traits for the location Manager.
    func locationManager()
    {
        Manager.delegate = self
        Manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Checks if locationServices are enabled, then initializes the location manager and then checks permissions for the app
    func locationServices()
    {
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager()
            Authorization()
        }
        // if location services are not on display an alert
        else
        {
            let privacyalert = UIAlertView()
            
            privacyalert.title = "LocationServices"
            privacyalert.addButton(withTitle: "Understood")
            privacyalert.message = "You Have Your Location Services Turned Off"
            
            privacyalert.show()
        }
    }
    
    
    
    func Authorization()
    {
        // check authorization, if authorized, set the region to the user and display the user icon.
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
        // if the user does not have permission display an alert
        else if CLLocationManager.authorizationStatus() == .denied
        {
            let privacyalert = UIAlertView()
            
            privacyalert.title = "LocationServices"
            privacyalert.addButton(withTitle: "Understood")
            privacyalert.message = "You Have Your Location Services Turned Off For The App"
            
            privacyalert.show()
        }
        // ask the user for permission
        else
        {
            Manager.requestWhenInUseAuthorization()
        }
    }
    
    func loadSelectedOptions()
    {
        //No other functionality in the options is used, so only add new pins.
        addPin()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? MapOptionsViewController)?.selectedOptions = selectedOptions
    }
    
    @IBAction func closeOptions(_ exitSegue: UIStoryboardSegue) {
        //When the options controller is closed, get necessary variables from the controller before closing.
        guard let vc = exitSegue.source as? MapOptionsViewController else { return }
        selectedOptions = vc.selectedOptions
        latitude = vc.latitude.text ?? ""
        longitude = vc.longitude.text ?? ""
        loadSelectedOptions()
        
        let date = NSDate()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.second, .minute, .hour, .day , .month , .year], from: date as Date)
        let year =  components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        
        //Add a notification at the hard-coded time
        let notificationMessage = NotificationManager()
        notificationMessage.notifications = [
            NotificationManager.Notification(id: "reminder-1", title: "Remember the milk!", datetime: DateComponents(calendar: Calendar.current, year: year, month: month, day: day, hour: hour, minute: (minute!)+1)),
        ]

        //Schedule the notification.
        notificationMessage.schedule()
    }
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        mapView.mapType = MKMapType.init(rawValue : UInt(sender.selectedSegmentIndex)) ?? .standard
    }
    
    func addPin() {
        // Ensure the longitude and latitude have values
        if longitude != "" && latitude != ""
        {
            // Convert them to doubles and create a coordinate based on those values.
            let lat = (latitude as NSString).doubleValue
            let lon = (longitude as NSString).doubleValue
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            // Create an Pin and add it to the map view.
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
        // Create a generalized annotation renderer to be used for the map Pins.
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
    func locationManager(_ manager : CLLocationManager, didUpdateLocations locations : [CLLocation])
    {
        guard let location = locations.last
            else {return}
        
        let center = CLLocationCoordinate2D(latitude:  location.coordinate.latitude, longitude : location.coordinate.longitude)
        
        let viewregion = MKCoordinateRegionMakeWithDistance(center, 200, 200)
        mapView.setRegion(viewregion, animated: true)
        
    }
    
    func locationManager(_ manager : CLLocationManager, didChangeAuthorization status : CLAuthorizationStatus)
    {
        Authorization()
    }
}
