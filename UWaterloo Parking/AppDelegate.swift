//
//  AppDelegate.swift
//  UWaterloo Parking
//
//  Created by 刘恒邑 on 16/2/17.
//  Copyright © 2016年 Hengyi Liu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.window?.rootViewController = storyboard.instantiateInitialViewController()
        self.window!.makeKeyAndVisible()
        
        // Override point for customization after application launch.
        let colour = UIColor(red: 252 / 255.0, green: 212 / 255.0, blue: 80 / 255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = colour
        
        UINavigationBar.appearance().barTintColor = colour
        UINavigationBar.appearance().tintColor = UIColor.black
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let shortcutType = ShortcutIdentifier(rawValue: shortcutItem.type) else {
            completionHandler(false)
            return
        }

        (window?.rootViewController as? UITabBarController)?.selectedIndex = shortcutType.index
        completionHandler(true)
    }
}
