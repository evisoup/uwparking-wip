//
//  TodayViewController.swift
//  DropDownWidget
//
//  Created by 刘恒邑 on 16/2/17.
//  Copyright © 2016年 Hengyi Liu. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    

    @IBOutlet var cCap: UILabel!
    @IBOutlet var nCap: UILabel!
    @IBOutlet var wCap: UILabel!
    @IBOutlet var xCap: UILabel!
    
    @IBOutlet var cPst: UILabel!
    @IBOutlet var nPst: UILabel!
    @IBOutlet var wPst: UILabel!
    @IBOutlet var xPst: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
          update()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        update()
        completionHandler(NCUpdateResult.newData)
    }
    

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize
        }
        else {
            //expanded
            self.preferredContentSize = CGSize(width: maxSize.width, height: 200)
        }
    }
    
    
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
                                let cap = data["capacity"] as? Int else{break}
                            
                            DispatchQueue.main.async{
                                switch name{
                                case "C" :
                                    self?.cCap.text = "\(count) / \(cap)"
                                    self?.cPst.text = "\(pct)%"
                                    
                                case "N" :
                                    self?.nCap.text = "\(count) / \(cap)"
                                    self?.nPst.text = "\(pct)%"
                                    
                                case "X" :
                                    self?.xCap.text = "\(count) / \(cap)"
                                    self?.xPst.text = "\(pct)%"
                                    
                                case "W" :
                                    self?.wCap.text = "\(count) / \(cap)"
                                    self?.wPst.text = "\(pct)%"
                                    
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
    
}
