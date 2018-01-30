//
//  HomeViewController.swift
//  UWaterloo Parking
//
//  Created by 刘恒邑 on 16/2/17.
//  Copyright © 2016年 Hengyi Liu. All rights reserved.
//

import UIKit

// MARK: - Private Constants

private let C_LOT_DETAILS = "cDetails"
private let N_LOT_DETAILS = "nDetails"
private let W_LOT_DETAILS = "wDetails"
private let X_LOT_DETAILS = "xDetails"

// MARK: - HomeViewController

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
    
    lazy private var uwAPICaller = UWAPICaller()
    
    @IBAction func toMap(_ sender: AnyObject) {
        tabBarController?.selectedIndex = 1
    }
    
    
    @IBAction func myRefresh(_ sender: AnyObject) {
        actind.startAnimating()
        updateUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "UWATERLOO PARKING"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case C_LOT_DETAILS, N_LOT_DETAILS, X_LOT_DETAILS, W_LOT_DETAILS:
            guard let destination = segue.destination as? LotsDetailController else { break }
            
            destination.lotID = identifier.prefix(1).uppercased()
        default:
            break
        }
    }
}

// MARK: - Private Extension

private extension HomeViewController {
    
    func composeString(inputs: Int...) -> String {
        switch inputs.count {
        case 1:
            return "\(inputs[0])%"
        case 2:
            return "\(inputs[0]) / \(inputs[1])"
        default:
            return ""
        }
    }
    
    func updateUI() {
        uwAPICaller.fetchParkingRequestResultV2(
            success: { [weak self] result in
                print("牛逼成功了")
                
                DispatchQueue.main.async {
                    _ = result.data.map {
                        let count = $0.currentCount
                        let cap = $0.cap
                        let pct = $0.percentFilled
                        
                        let capText = self?.composeString(inputs: count, cap)
                        let pctText = self?.composeString(inputs: pct)
                        
                        switch $0.lotName {
                        case LotName.C.rawValue :
                            self?.cCap.text = capText
                            self?.cPct.text = pctText
                        case LotName.N.rawValue :
                            self?.nCap.text = capText
                            self?.nPct.text = pctText
                        case LotName.X.rawValue :
                            self?.xCap.text = capText
                            self?.xPct.text = pctText
                        case LotName.W.rawValue :
                            self?.wCap.text = capText
                            self?.wPct.text = pctText
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
}

