//
//  ViewController.swift
//  pinMyLocation
//
//  Created by Huiwen You on 2016-02-16.
//  Copyright © 2016 FORCE. All rights reserved.
//

import UIKit
import MapKit

class PinViewController: UIViewController, CLLocationManagerDelegate {
    
    var manager: CLLocationManager!
    var userLocation: CLLocation!
    var pinMyCar: Bool = false
    let defaults: UserDefaults = UserDefaults.standard
    var carLocationCleared: Bool = false
    
    @IBOutlet weak var mapContainer: MKMapView!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        self.navigationItem.title = "PIN"
        reloadMap()
        mapContainer.showsUserLocation = true
        mapContainer.showsCompass = true
        mapContainer.showsBuildings = true
        mapContainer.mapType = .hybrid
        
        let from3dtouch: Bool = RestApiManager.sharedInstance.getsource3Dtouch()
        if from3dtouch {
            //print("from3dtouch!")
            dropPin()
        } else {
            //print("default view")
        }
    }
    
    func reloadMap() {
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    @IBAction func clearCarLocationPin(_ sender: AnyObject) {
        if defaults.double(forKey: "myCarLatitude") != 0.0 && defaults.double(forKey: "myCarLongitude") != 0.0
            && !carLocationCleared
        {
            //clear saved value
            defaults.removeObject(forKey: "myCarLatitude")
            defaults.removeObject(forKey: "myCarLongitude")
            carLocationCleared = true
            //remove pin annotation
            //if pinMyCar {
                let annotationsToRemove = mapContainer.annotations.filter { $0 !== mapContainer.userLocation }
                mapContainer.removeAnnotations( annotationsToRemove )
            //}
            //reload map
            reloadMap()
        }
    }
    
    @IBAction func mapTypeToggle(_ sender: AnyObject) {
        if (mapContainer.mapType == .hybrid) {
            mapContainer.mapType = .standard
        } else {
            mapContainer.mapType = .hybrid
        }
    }
    
    @IBAction func pin(_ sender: AnyObject) {
        self.dropPin()
    }
    
    func dropPin() {
        reloadMap()
        pinMyCar = true
        carLocationCleared = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        let latDelta:CLLocationDegrees = 0.01
        let longDelta:CLLocationDegrees = 0.01
        
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta,longDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        
        mapContainer.showsUserLocation = true
        mapContainer.showsCompass = true
        mapContainer.showsBuildings = true
        mapContainer.setRegion(region, animated: true)
        
        if defaults.double(forKey: "myCarLatitude") != 0.0 && defaults.double(forKey: "myCarLongitude") != 0.0 && !carLocationCleared
        {
            //print("previous car location exists")
            let carLat: Double = defaults.double(forKey: "myCarLatitude")
            let carLong: Double = defaults.double(forKey: "myCarLongitude")
            if pinMyCar {
                //remove previous car annotation
                let annotationsToRemove = mapContainer.annotations.filter { $0 !== mapContainer.userLocation }
                mapContainer.removeAnnotations( annotationsToRemove )
                
                //save new car loacation i.e. current location
                defaults.set(latitude, forKey: "myCarLatitude")
                defaults.set(longitude, forKey: "myCarLongitude")
                
                //draw new pin on the map i.e. current location
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = coordinate
                annotation.title = "MyCarLocation"
                annotation.subtitle = "\(latitude) / \(longitude)"
                self.mapContainer.addAnnotation(annotation)
                
            } else {
                //view on load
                //draw previous pinned car location on the map
                let annotation = MKPointAnnotation()
                let pinnedCarCoordinates = CLLocationCoordinate2DMake(carLat, carLong)
                annotation.coordinate = pinnedCarCoordinates
                annotation.title = "MyCarLocation"
                annotation.subtitle = "\(carLat) / \(carLong)"
                self.mapContainer.addAnnotation(annotation)
            }
        } else {
            //print("no previous car location")
            if pinMyCar && !carLocationCleared {
                //save car loacation i.e. current location
                defaults.set(latitude, forKey: "myCarLatitude")
                defaults.set(longitude, forKey: "myCarLongitude")
                
                //draw new pin on the map i.e. current location
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "MyCarLocation"
                annotation.subtitle = "\(latitude) / \(longitude)"
                
                self.mapContainer.addAnnotation(annotation)
            }
        }
        manager.stopUpdatingLocation()
    }
    
    func centerMapOnMyCarLocation() {
        let latDelta:CLLocationDegrees = 0.01
        let longDelta:CLLocationDegrees = 0.01
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta,longDelta)
        
        if defaults.double(forKey: "myCarLatitude") != 0.0 && defaults.double(forKey: "myCarLongitude") != 0.0 {
            //car location pinned
            let carLat: Double = defaults.double(forKey: "myCarLatitude")
            let carLong: Double = defaults.double(forKey: "myCarLongitude")
            let coordinate = CLLocationCoordinate2DMake(carLat, carLong)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
            mapContainer.setRegion(region, animated: true)
        }
    }
    
    @IBAction func findCarBtn(_ sender: AnyObject) {
        centerMapOnMyCarLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

