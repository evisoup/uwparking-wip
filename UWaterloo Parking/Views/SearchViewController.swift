//
//  ViewController.swift
//  searchtab
//
//  Created by Phoenix on 2016-02-18.
//  Copyright © 2016 Phoenix. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UIViewController, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet var buildingTable: UITableView!
    
    @IBOutlet var selectInfo: UILabel!
    
    @IBOutlet var lotInfo: UILabel!
    
    @IBOutlet var traveltimeInfo: UILabel!
    
    
    struct Building {
        var name: String
        var code: String
        var latitude: Double
        var longitude: Double
    }
    
    var buildinglist = [Building]()
    var filteredData: [Building]!
    
    struct Lot {
        var name: String
        var latitude: Double
        var longitude: Double
        
    }
    
    var lotlist = [Lot]()
    
    var searchController: UISearchController!
    
    
    func GetData() {
        
        let url = URL(string: "https://api.uwaterloo.ca/v2/parking/watpark.json?key=")!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            
            if let urlContent = data {
                
                do {
                    
                    let object = try JSONSerialization.jsonObject(with: urlContent, options: .allowFragments)
                    
                    if let dictionary = object as? [String: AnyObject]{
                        guard let datas = dictionary["data"] as? [[String: AnyObject]] else {return}
                        
                        self.lotlist = [Lot]()
                        
                        for data in datas {
                            
                            guard let strName  = data["lot_name"] as? String,
                                let dblLatitude = data["latitude"] as? Double,
                                let dblLongitude = data["longitude"] as? Double else{break}
                            
                            self.lotlist.append(Lot(name:strName, latitude:dblLatitude, longitude:dblLongitude))
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
        
        buildingTable.dataSource = self
        filteredData = Buildingdata
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.sizeToFit()
        buildingTable.tableHeaderView = searchController.searchBar
        
        
        searchController.searchBar.placeholder = "Get Walking Estimate"
        
        searchController.searchBar.layer.borderColor = UIColor(red: 252/255.0, green: 212/255.0, blue: 80/255.0, alpha: 1.0).cgColor
        searchController.searchBar.layer.borderWidth = 1
        searchController.searchBar.barTintColor = UIColor(red: 252/255.0, green: 212/255.0, blue: 80/255.0, alpha: 1.0)
        searchController.searchBar.tintColor = UIColor.black
        
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        
        buildingTable.layer.masksToBounds = true
        buildingTable.layer.borderColor = UIColor(red: 252/255.0, green: 212/255.0, blue: 80/255.0, alpha: 1.0).cgColor
        buildingTable.layer.borderWidth = 1.0
        
        definesPresentationContext = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.willEnterForground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        GetData()
        
    }
    
    func willEnterForground() {
        GetData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GetData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = buildingTable.dequeueReusableCell(withIdentifier: "buildingcell")! as UITableViewCell
        cell.textLabel?.text = filteredData[(indexPath as NSIndexPath).row].code + " - " + filteredData[(indexPath as NSIndexPath).row].name
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 252/255.0, green: 212/255.0, blue: 80/255.0, alpha: 1.0)
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    private func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        let searchCode = self.filteredData[(indexPath as NSIndexPath).row].code
        let searchLatitude = self.filteredData[(indexPath as NSIndexPath).row].latitude
        let searchLongitude = self.filteredData[(indexPath as NSIndexPath).row].longitude
        searchController.isActive = false
        searchController.searchBar.resignFirstResponder()
        
        self.buildingTable.allowsSelection=false
        self.buildingTable.alpha = 0.3
        
        self.selectInfo.text = searchCode
        self.lotInfo.text = "Searching . . ."
        self.traveltimeInfo.text = ""
        
        var tmpTime = 0.0
        var tmpLot:String = ""
        var tmpRequestTime = 0.0
        var notprint = false
        
        if (searchLatitude == 0.0 || searchLongitude == 0.0) {
            self.buildingTable.allowsSelection=true
            self.buildingTable.alpha = 1
            notprint = true
            self.selectInfo.text = searchCode
            self.lotInfo.text = "Not Available"
            return
        } else {
            
            let markSelection = MKPlacemark(coordinate: CLLocationCoordinate2DMake(searchLatitude, searchLongitude), addressDictionary: nil)
            
            
            for index in 0..<self.lotlist.count {

                let markDestLot = MKPlacemark(coordinate: CLLocationCoordinate2DMake(self.lotlist[index].latitude, self.lotlist[index].longitude), addressDictionary: nil)
                
                let request = MKDirectionsRequest()
                request.source = MKMapItem(placemark: markSelection)
                request.destination = MKMapItem(placemark: markDestLot)
                request.transportType = .walking
                
                let direction = MKDirections(request: request)
                direction.calculateETA { response, error -> Void in
                    if error != nil {

                        self.buildingTable.allowsSelection=true
                        self.buildingTable.alpha = 1
                        self.selectInfo.text = searchCode

                        self.lotInfo.text = "Not Available"
                        
                        self.traveltimeInfo.text = ""
                        notprint = true
                        return
                    }
                    tmpRequestTime = response!.expectedTravelTime/60
                    
                    if tmpTime == 0.0 {
                        tmpTime = tmpRequestTime
                        tmpLot = self.lotlist[index].name
                    } else if tmpRequestTime < tmpTime {
                        tmpTime = tmpRequestTime
                        tmpLot = self.lotlist[index].name
                    }
                }
                
            }
            
            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                if (!notprint) {
                    self.selectInfo.text = searchCode
                    if (tmpLot == "" || Int(round(tmpTime)) == 0) {
                        self.buildingTable.allowsSelection=true
                        self.buildingTable.alpha = 1
                        self.lotInfo.text = "Please try again"
                        self.traveltimeInfo.text = ""
                    } else {
                        self.buildingTable.allowsSelection=true
                        self.buildingTable.alpha = 1
                        self.lotInfo.text = "\(tmpLot) "
                        let displayTime = Int(round(tmpTime))
                        self.traveltimeInfo.text = "\(displayTime) minutes"
                    }
                }
            }
        }
        
    }
    
    
    @IBAction func top(_ sender: AnyObject) {
        buildingTable.setContentOffset(CGPoint.zero, animated:true)
    }
    func updateSearchResults(for searchController: UISearchController) {
        self.selectInfo.text = ""
        self.lotInfo.text = ""
        self.traveltimeInfo.text = ""
        if let searchText = searchController.searchBar.text {
            filteredData = searchText.isEmpty ? Buildingdata : Buildingdata.filter({
                return ($0.name.range(of: searchText, options: .caseInsensitive) != nil) || ($0.code.range(of: searchText, options: .caseInsensitive) != nil)
            })
            
            buildingTable.reloadData()
        }
        buildingTable.setContentOffset(CGPoint.zero, animated:true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

