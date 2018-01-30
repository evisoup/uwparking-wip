//
//  jsonParser.swift
//  UWaterloo Parking
//
//  Created by 刘恒邑 on 2017/12/4.
//  Copyright © 2017年 Hengyi Liu. All rights reserved.
//

import Foundation
import UIKit

struct UWParkingRequest: Codable {
    
    struct UWParkingData: Codable {
        let lotName: String
        let cap: Int
        let currentCount: Int
        let percentFilled: Int
        let latitude: Double
        let longitude: Double
        let lastUpdated: String
        
        private enum CodingKeys : String, CodingKey {
            case lotName = "lot_name"
            case cap = "capacity"
            case currentCount = "current_count"
            case percentFilled = "percent_filled"
            case latitude
            case longitude
            case lastUpdated = "last_updated"
        }
    }
    
    struct UWParkingMeta: Codable {
        let requests: Int
        let timestamp: Int
        let status: Int
        /// TODO: add coding keys maybe?
    }
    
    let meta: UWParkingMeta
    let data: [UWParkingData]
}

public enum LotName: String {
    case C,N,W,X
}
