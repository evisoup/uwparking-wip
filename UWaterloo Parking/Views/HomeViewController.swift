//
//  HomeViewController.swift
//  UWaterloo Parking
//
//  Created by 刘恒邑 on 16/2/17.
//  Copyright © 2016年 Hengyi Liu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet var actind: UIActivityIndicatorView!
    
    @IBOutlet var cCap: UILabel!
    @IBOutlet var cPct: UILabel!
    
    @IBOutlet var nCap: UILabel!
    @IBOutlet var nPct: UILabel!
    
    @IBOutlet var wCap: UILabel!
    @IBOutlet var wPct: UILabel!
    
    @IBOutlet var xCap: UILabel!
    @IBOutlet var xPct: UILabel!
    
    
    @IBAction func toMap(_ sender: AnyObject) {
        tabBarController?.selectedIndex = 1
    }
    
    
    @IBAction func myRefresh(_ sender: AnyObject) {
        actind.startAnimating()
        updateUI()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "UWATERLOO PARKING"
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.willEnterForground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        // updateUI()
    }
    
    func willEnterForground() {
        //updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: 改到switch
        if(segue.identifier == "cDetails" ){
            if let destinationVC = segue.destination as? LotsDetailController{
                destinationVC.lotID  =  "C"
            }
        }
        
        if(segue.identifier == "nDetails" ){
            if let destinationVC = segue.destination as? LotsDetailController{
                destinationVC.lotID  =  "N"
            }
        }
        
        if(segue.identifier == "xDetails" ){
            if let destinationVC = segue.destination as? LotsDetailController{
                destinationVC.lotID  =  "X"
            }
        }
        
        if(segue.identifier == "wDetails" ){
            if let destinationVC = segue.destination as? LotsDetailController{
                destinationVC.lotID  =  "W"
            }
        }
    }
    
    func updateUI() {
        UWApiCall.fetchParkingRequestResultV2(
            success: { [weak self] result in
                print("牛逼成功了")
                
                DispatchQueue.main.async {
            
                    let _ = result.data.map {
                        let count = $0.currentCount
                        let cap = $0.cap
                        let pct = $0.percentFilled
                        
                        switch $0.lotName {
                        case "C" :
                            // TODO: 写一个string generator？
                            self?.cCap.text = "\(count) / \(cap)"
                            self?.cPct.text = "\(pct)%"
                            
                        case "N" :
                            self?.nCap.text = "\(count) / \(cap)"
                            self?.nPct.text = "\(pct)%"
                            
                        case "X" :
                            self?.xCap.text = "\(count) / \(cap)"
                            self?.xPct.text = "\(pct)%"
                            
                        case "W" :
                            self?.wCap.text = "\(count) / \(cap)"
                            self?.wPct.text = "\(pct)%"
                            
                        default:
                            break
                        }
                    }
                }
            },
            failure: {
                print("call back failure")
        })
    }
    
///////
}
