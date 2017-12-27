//
//  File.swift
//  UWaterloo Parking
//
//  Created by 刘恒邑 on 2017/5/14.
//  Copyright © 2017年 Hengyi Liu. All rights reserved.
//

import Foundation


class Receiver {
    
    private let apiUrl = URL(string: "https://api.uwaterloo.ca/v2/parking/watpark.json?key=")!
    
    enum Lot {
        case c
        case n
        case w
        case x
    }

    var lotX: (Int?,Int?,Int?)
    var lotC: (Int?,Int?,Int?)
    var lotN: (Int?,Int?,Int?)
    var lotW: (Int?,Int?,Int?)
//        {
//        get {
//            return fetchResult(for: .w)
//        }
//        set {
//            
//        }
//    }

    
    
    func fetchResult() {
        
        
        var num: Int?
        var total: Int?
        var percentage: Int?
        
        let task = URLSession.shared.dataTask(with: apiUrl) { [weak self] (data, response, err) in
            
            if let urlContent = data {
                do {
                    
                    let object = try JSONSerialization.jsonObject(with: urlContent, options: .allowFragments)
                    
                     if let dictionary = object as? [String: AnyObject] {
                        
                        guard let datas = dictionary["data"] as? [[String: AnyObject]] else {return}
                        
                        for data in datas {
                            guard let name  = data["lot_name"] as? String,
                                let count = data["current_count"] as? Int,
                                let pct = data["percent_filled"] as? Int,
                                let cap = data["capacity"] as? Int else { break }
                            
                            switch name{
                            case "C" :
                                if name == "C" {
                                    num = count
                                    total = cap
                                    percentage = pct
                                    self?.lotC = (num,total,percentage)
                                }
                            case "N" :
                                if name == "N" {
                                    num = count
                                    total = cap
                                    percentage = pct
                                    self?.lotN = (num,total,percentage)
                                }
                            case "X" :
                                if name == "X" {
                                    num = count
                                    total = cap
                                    percentage = pct
                                    self?.lotX = (num,total,percentage)
                                }
                            case "W":
                                if name == "W" {
                                    num = count
                                    total = cap
                                    percentage = pct
                                    self?.lotW = (num,total,percentage)
                                }
                                
                            default:
                                break
                        
                            }
                        }
                    }
                    
                } catch {
                    print("JSON serialization failed")
                }
            }
        }
        
        task.resume()
        //return (num,total,percentage)
        
    }
    
    
    
    
    
    
    
    
}
