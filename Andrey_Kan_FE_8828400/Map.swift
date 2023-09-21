//
//  Map.swift
//  Andrey_Kan_FE_8828400
//
//  Created by Andrey Kan on 05.08.2023.
//

import UIKit
import CoreLocation
import MapKit

class Map: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var slider: UISlider!
    
    
    @IBOutlet weak var locationTextView: UITextView!
    
    var place: PlaceData?
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        // receive data from Main 
        if let placeData = place {
            let cityName = "City: \(placeData.name ?? "cityName")"
            let longitude = "Longitude: \(placeData.longitude)"
            let latitude = "Latitude: \(placeData.latitude)"
            locationTextView.text! = cityName + "\n" + longitude + "\n" + latitude
            let location = CLLocation(latitude: placeData.latitude, longitude: placeData.longitude)
            render(location: location, zoom: slider.value)
        }
    }
    
    
    
    // render map
    func render (location: CLLocation, zoom: Float){
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(zoom), longitudeDelta: CLLocationDegrees(zoom)) // defines zoom
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        let pin = MKPointAnnotation()
        
        pin.coordinate = coordinate

        map.addAnnotation(pin)
        
        map.setRegion(region, animated: true)
        
    }
    
    // re-render map when slider value is changed
    @IBAction func sliderChanged(_ sender: UISlider) {
        if let placeData = place {
            let location = CLLocation(latitude: placeData.latitude, longitude: placeData.longitude)
            render(location: location, zoom: sender.value)
        }
        
    }
    

}
