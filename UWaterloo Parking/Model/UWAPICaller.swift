//
//  ApiRequester.swift
//  UWaterloo Parking
//
//  Created by 刘恒邑 on 2017/12/4.
//  Copyright © 2017年 Hengyi Liu. All rights reserved.
//

import Foundation
import UIKit

class UWAPICaller {
    
    private let API_KEY = APIKey.Key
    private var fetching = false
    
    func getURL() -> URL {
        // TODO: to remove
        //let urlString = "https://api.uwaterloo.ca/v2/parking/watpark.json?key="
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.uwaterloo.ca"
        components.path = "/v2/parking/watpark.json"
        let queryItemToken = URLQueryItem(name: "key", value: API_KEY)
        components.queryItems = [queryItemToken]
        
        return components.url!
    }
    
    func fetchParkingRequestResultV2(success: @escaping (UWParkingRequest) -> Void , failure: @escaping () -> Void) {
        guard fetching == false else { return }
        
        fetching = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let url = self?.getURL() else { self?.fetching = false; return }
            
            URLSession.shared.dataTask(with: url) { data, response, err in
                self?.fetching = false
                guard let data = data else { failure(); return }
                
                do {
                    let parkingLotsRequest = try JSONDecoder().decode(UWParkingRequest.self, from: data)
                    guard parkingLotsRequest.data.count == 4 else { failure(); return }
                    
                    success(parkingLotsRequest)
                } catch let jsonParsingErr {
                    failure()
                    print("parsing error: \(jsonParsingErr)")
                }
            }.resume()
        }
    }
}
