//
//  ViewController.swift
//  MapPages
//
//  Created by Huiwen You on 2016-02-12.
//  Copyright © 2016 FORCE. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var mapContainer: MKMapView!
    
    var latC: CLLocationDegrees = 0.0
    var longC: CLLocationDegrees = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let latitude:CLLocationDegrees = 43.472761
        let longitude:CLLocationDegrees = -80.542164
        
        let latDelta:CLLocationDegrees = 0.05 //0.02
        let longDelta:CLLocationDegrees = 0.05 //0.02
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta,longDelta)
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        mapContainer.delegate = self
        
        mapContainer.setRegion(region, animated: true)
        mapContainer.showsUserLocation = true
        mapContainer.showsCompass = true
        mapContainer.mapType = .hybrid
        
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.willEnterForground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        self.update()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.update()
    }
    
    func update() {
        self.setParkingLot("C")
        self.setParkingLot("N")
        self.setParkingLot("W")
        self.setParkingLot("X")
    }
    
    func willEnterForground() {
        self.update()
    }
    
    @IBAction func mapTypeToggle(_ sender: AnyObject) {
        if (mapContainer.mapType == .hybrid) {
            mapContainer.mapType = .standard
        } else {
            mapContainer.mapType = .hybrid
        }
    }

    func mapView(_ mapView: MKMapView,
        viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if !(annotation is CustomPointAnnotation) {
                //return nil so map view draws "blue dot" for standard user location
                return nil
            }
            
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as MKAnnotationView!
            if pinView == nil {
                pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                pinView!.isEnabled = true

                let btn = UIButton(type: .detailDisclosure)
                pinView!.rightCalloutAccessoryView = btn
            }
            else {
                pinView!.annotation = annotation
            }
            
            let cpa = annotation as! CustomPointAnnotation
            pinView!.image = UIImage(named:cpa.imageName)
            
            return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {

        guard let customedPin = view.annotation,
            let tempName = customedPin.title,
            let tempSub = customedPin.subtitle,
            let lotName = tempName,
            let data = tempSub else {
            return
        }
        
        let ac = UIAlertController(title: lotName, message: data, preferredStyle: .alert)
        ac.addAction(UIAlertAction(
            title: "Navigation", style: UIAlertActionStyle.default, handler: { action in
                
                let currentLocation = MKMapItem.forCurrentLocation()
                
                let markDestLocation: MKPlacemark
                switch lotName {
                case "Parking Lot: C" : //entrance coordinate: 43.468307, -80.538341
                    markDestLocation = MKPlacemark(coordinate: CLLocationCoordinate2DMake(43.468307, -80.538341))
                case "Parking Lot: W" : //entrance coord: 43.475349, -80.547078
                    markDestLocation = MKPlacemark(coordinate: CLLocationCoordinate2DMake(43.475349, -80.547078))
                case "Parking Lot: X" ://entrance coord: 43.476466, -80.546562
                    markDestLocation = MKPlacemark(coordinate: CLLocationCoordinate2DMake(43.476466, -80.546562))
                default:
                    markDestLocation = MKPlacemark(coordinate: CLLocationCoordinate2DMake((customedPin.coordinate.latitude), (customedPin.coordinate.longitude)))
                }

                let destLocation = MKMapItem(placemark: markDestLocation)
                
                destLocation.name = lotName
                
                let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                MKMapItem.openMaps(with: [currentLocation, destLocation], launchOptions: launchOptions)
            }
            ))
        ac.addAction(UIAlertAction(
            title: "Cancel", style: UIAlertActionStyle.default, handler: { action in
                ac.dismiss(animated: true, completion: nil)
            }
        ))
        present(ac, animated: true, completion: nil)
    }
    
    
    func setParkingLot(_ lot: String!) {
        let annotation = CustomPointAnnotation()
        
        RestApiManager.sharedInstance.getParkingLotLocation(lot) {
            (latitude: Double, longitude: Double) in
            RestApiManager.sharedInstance.getCurrentCountAndCapacity(lot) {
                (count: Int, capacity: Int) in
                DispatchQueue.main.async(execute: {
                    if (latitude != 0.00 && longitude != 0.00) {
                        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
                        
                        annotation.coordinate = location
                        annotation.title = "Parking Lot: " + lot
                        
                        if count == -1 || capacity == -1 {
                            annotation.subtitle = "Data not available!"
                        } else {
                            annotation.subtitle = "\(count) / \(capacity)"
                        }
                        
                        if (lot == "C") {
                            annotation.imageName = "iconc.png"
                        }
                        if (lot == "N") {
                            annotation.imageName = "iconn.png"
                        }
                        if (lot == "W") {
                            annotation.imageName = "iconw.png"
                        }
                        if (lot == "X") {
                            annotation.imageName = "iconx.png"
                        }
                        
                        self.mapContainer.addAnnotation(annotation)
                    }
                })
            }
        }
    }
}


class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
}
