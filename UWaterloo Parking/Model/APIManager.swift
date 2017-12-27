//
//  APIManager.swift
//  servicestab
//
//  Created by Phoenix on 2016-02-13.
//  Copyright © 2016 Phoenix. All rights reserved.
//

import Foundation


//typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
    
    let APIkey = ""
    
    var basebuildingURL = "https://api.uwaterloo.ca/v2/buildings/list.json"

    //https://api.uwaterloo.ca/v2/buildings/list.json?key=
    
    
    var parkingReqURL = "https://api.uwaterloo.ca/v2/parking/watpark.json?key="
    
    var source3Dtouch: Bool = false
    
    func getsource3Dtouch() -> Bool {
        return self.source3Dtouch
    }
    
    func setsource3Dtouch(_ data: Bool) -> Void {
        self.source3Dtouch = data
    }
    
    func getBuildingData(_ onCompletion: @escaping (JSON) -> Void) {
        makeHTTPGetRequest(basebuildingURL+"?key="+APIkey, onCompletion: { json, err in
            onCompletion(json! as JSON)
        })
    }
    
    
    
    
    
    //helen
    func getParkingLotLocation(_ lot: String, onCompletion: @escaping (_ latitude: Double, _ longitude: Double) -> Void) {
        let route = parkingReqURL
        makeHTTPGetRequest(route) { (obj, err) in
            var latitude: Double = 0.00
            var longitude: Double = 0.00
            //let lotList = obj["data"]
            if obj != nil {
                let lotList = obj!["data"]
                for (index: _, subJson) in lotList {
                    let lotName = subJson["lot_name"].string
                    if lotName == lot {
                        latitude = subJson["latitude"].double!
                        longitude = subJson["longitude"].double!
                        break
                    }
                }
            }
            onCompletion(latitude, longitude)
        }
        
    }
    
    func getCurrentCountAndCapacity(_ lot: String, onCompletion: @escaping (_ count: Int, _ capacity: Int) -> Void) {
        let route = parkingReqURL
        //var count = -1
        makeHTTPGetRequest(route) { (obj, err) in
            var count: Int = -1
            var capacity: Int = -1
            //let data = obj["data"]
            if obj != nil {
                let data = obj!["data"]
                for (index: _, subJson) in data {
                    let lotName = subJson["lot_name"].string
                    if lotName == lot {
                        count = subJson["current_count"].int!
                        capacity = subJson["capacity"].int!
                        break
                    }
                }
            }
            onCompletion(count, capacity)
        }
    }
    //helen
    
    
    
    
    func makeHTTPGetRequest(_ path: String, onCompletion: @escaping (JSON?, NSError?) -> Void) {
        
        let urlRequest = URLRequest(url: URL(string: path)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: {data, response, err -> Void in
            if data == nil {
                //var data: Data? = nil
                onCompletion(nil, err as NSError?)
            } else {
                try? onCompletion(JSON(data: data!), err as NSError?)
            }
        })
        task.resume()
    }
}
