//
//  ViewController.swift
//  servicestab
//
//  Created by Phoenix on 2016-02-13.
//  Copyright © 2016 Phoenix. All rights reserved.
//

import UIKit
import MapKit

class InfoViewController: UIViewController {
    
    @IBOutlet var desc: UILabel!
    
    @IBOutlet var locationinput: UILabel!
    
    @IBOutlet var hoursinput: UILabel!
    
    @IBOutlet var phoneinput: UILabel!
    
    @IBOutlet var emailinput: UILabel!
    
    @IBOutlet var homepageinput: UIButton!
    
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    
    
    
    func GetData() {
        
        let url = URL(string: "https://api.uwaterloo.ca/v2/poi/visitorinformation.json?key=")!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            
            if let urlContent = data {
                
                do {
                    
                    let object = try JSONSerialization.jsonObject(with: urlContent, options: .allowFragments)
                    
                    if let dictionary = object as? [String: AnyObject]{
                        guard let datas = dictionary["data"] as? [[String: AnyObject]] else {return}
                        
                        for data in datas {
                            
                            guard let tmpname = data["name"] as? String else{break}
                            
                            
                            if tmpname == "Parking Services" {
                                
                                guard let strDesc  = data["description"] as? String,
                                    let strHoursinput = data["opening_hours"] as? String,
                                    let strLocationinput = data["note"] as? String,
                                    let strPhoneinput = data["phone"] as? String,
                                    let strEmailinput = data["email"] as? String,
                                    let strHomepageinput = data["url"] as? String,
                                    let dblLatitude = data["latitude"] as? Double,
                                    let dblLongitude = data["longitude"] as? Double else{break}
                                
                                
                                DispatchQueue.main.async(execute: {
                                    self.desc.text =  strDesc
                                    self.hoursinput.text =  strHoursinput
                                    self.locationinput.text =  strLocationinput + "  154"
                                    self.phoneinput.text =  strPhoneinput
                                    self.emailinput.text =  strEmailinput
                                    self.homepageinput.setTitle(strHomepageinput, for: UIControlState())
                                    self.latitude = dblLatitude
                                    self.longitude = dblLongitude
                                })
                                break
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "INFO"
        
        NotificationCenter.default.addObserver(self, selector: #selector(InfoViewController.willEnterForground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        GetData()
    
    }
    
    
    @objc func willEnterForground() {
        GetData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GetData()
    }
    
    @IBAction func homepageDir(_ sender: AnyObject) {
        
        UIApplication.shared.open(URL(string: self.homepageinput.currentTitle! )!)
    }
    
    @IBAction func Direaction(_ sender: AnyObject) {
        
        let currentLocation = MKMapItem.forCurrentLocation()
        let markDestLocation = MKPlacemark(coordinate: CLLocationCoordinate2DMake(self.latitude, self.longitude), addressDictionary: nil)
        let destLocation = MKMapItem(placemark: markDestLocation)
        
        destLocation.name = "Parking Services"
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        MKMapItem.openMaps(with: [currentLocation, destLocation], launchOptions: launchOptions)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}

