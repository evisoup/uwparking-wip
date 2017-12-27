//
//  LotsDetailController.swift
//  UWaterloo Parking
//
//  Created by 刘恒邑 on 16/2/17.
//  Copyright © 2016年 Hengyi Liu. All rights reserved.
//

import UIKit
import MapKit

@IBDesignable
class LotsDetailController: UIViewController {
    
    
    
    @IBOutlet var lotCap: UILabel!
    @IBOutlet var lotPct: UILabel!
    @IBOutlet var lotTime: UILabel!
    @IBOutlet var lotName: UILabel!
    
  
    @IBInspectable
    var progress: KDCircularProgress!
    var latitude: Double! = 43.467536
    var longitude: Double! = -80.538379
    var lotPctDouble: Double!
    var lotID = String()
    
    
    func update() {
        
        let url = URL(string: "https://api.uwaterloo.ca/v2/parking/watpark.json?key=")!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, response, error) -> Void in
            
            if let urlContent = data {
                
                do {
                    
                    let object = try JSONSerialization.jsonObject(with: urlContent, options: .allowFragments)
                    
                    if let dictionary = object as? [String: AnyObject]{
                        guard let datas = dictionary["data"] as? [[String: AnyObject]] else {return}
                        
                        for data in datas {
                            guard let name  = data["lot_name"] as? String,
                                let count = data["current_count"] as? Int,
                                let pct = data["percent_filled"] as? Int,
                                let lat = data["latitude"] as? Double,
                                let lon = data["longitude"] as? Double,
                                
                                let cap = data["capacity"] as? Int else{break}
                            
                            DispatchQueue.main.async{
                                switch name{
                                case (self?.lotID)! :
                                    self?.lotCap.text = "\(count) / \(cap)"
                                    self?.lotPct.text = "\(pct)%"
                                    self?.lotPctDouble = Double(pct)
                                    
                                    let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
                                    self?.lotTime.text = "\(timestamp)"
                                    
                                    self?.latitude = lat
                                    self?.longitude = lon
                                    self?.circularRender()
                                    
                                default:
                                    break
                                }
                            }
                        }
                    }
            
                } catch {
                    print("JSON serialization failed")
                }
                
            }
            
        }) 
        
        task.resume()
        
    }
    
    
    func circularRender() {
        let angle = 360 * ( self.lotPctDouble * 0.01 )
        progress.animate(fromAngle: 0, toAngle: angle, duration: 1)
            { completed in
                if completed {
                    //print("animation stopped, completed")
                } else {
                    //print("animation stopped, was interrupted")
                }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LotsDetailController.willEnterForground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        progress.startAngle = -90
        progress.progressThickness = 0.25
        progress.trackThickness = 0.25
        progress.trackColor = UIColor(red: 246/255.0, green: 244/255.0, blue: 209/255.0, alpha: 1.0)
        progress.clockwise = true
        progress.gradientRotateSpeed = 1
        progress.roundedCorners = false
        progress.glowMode = .forward
        progress.glowAmount = 0
        progress.set(colors: UIColor(red: 252/255.0, green: 212/255.0, blue: 80/255.0, alpha: 1.0))
        
        //let ssize:CGRect = UIScreen.main.bounds
        
        progress.center = CGPoint(x: view.center.x, y: view.center.y - 40)

//        if ssize.height == 480.0 {
//            progress.center = CGPoint(x: view.center.x, y: view.center.y - 10)
//        } else if ssize.height == 736.0 {
//            progress.center = CGPoint(x: view.center.x, y: view.center.y - 100)
//        } else if ssize.height == 568.0 {
//            progress.center = CGPoint(x: view.center.x, y: view.center.y - 45)
//        } else {
//            progress.center = CGPoint(x: view.center.x, y: view.center.y - 80)
//        }
//        
        lotName.text = "Lot " + lotID //set up by segue, thus not in update
        lotName.layer.masksToBounds = true;
        lotName.layer.cornerRadius = 8.0;
        view.addSubview(progress)
        update()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func willEnterForground() {
        update()
    }

    @IBAction func Direction(_ sender: AnyObject) {
        
        let currentLocation = MKMapItem.forCurrentLocation()
        
        let markDestLocation: MKPlacemark
        
        switch lotID {
        case "C": //entrance coordinate: 43.468307, -80.538341
            markDestLocation = MKPlacemark(coordinate: CLLocationCoordinate2DMake(43.468307, -80.538341))
        case "W": //entrance coord: 43.475349, -80.547078
            markDestLocation = MKPlacemark(coordinate: CLLocationCoordinate2DMake(43.475349, -80.547078))
        case "X"://entrance coord: 43.476466, -80.546562
            markDestLocation = MKPlacemark(coordinate: CLLocationCoordinate2DMake(43.476466, -80.546562))
            
        default:
            markDestLocation = MKPlacemark(coordinate: CLLocationCoordinate2DMake(self.latitude, self.longitude))
        }
//        let markDestLocation = MKPlacemark(coordinate: CLLocationCoordinate2DMake(self.latitude, self.longitude), addressDictionary: nil)
        let destLocation = MKMapItem(placemark: markDestLocation)
        
        destLocation.name = "Parking Lot \(lotID)"

        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        MKMapItem.openMaps(with: [currentLocation, destLocation], launchOptions: launchOptions)
    }
    
    
    
}
