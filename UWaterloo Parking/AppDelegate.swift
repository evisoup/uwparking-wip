//
//  AppDelegate.swift
//  UWaterloo Parking
//
//  Created by 刘恒邑 on 16/2/17.
//  Copyright © 2016年 Hengyi Liu. All rights reserved.
//

import UIKit

@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate,  {
class AppDelegate: UIResponder, UIApplicationDelegate  {
    var window: UIWindow?
    
    func grabStoryBoard() -> UIStoryboard {
        var storyboard = UIStoryboard()
        let height = UIScreen.main.bounds.size.height
        
        if height == 667.0 {
            storyboard = UIStoryboard(name: "Main", bundle: nil)
        } else if height == 736.0 {
            storyboard = UIStoryboard(name: "MainForPlus", bundle: nil)
        } else if height == 568.0 {
            storyboard = UIStoryboard(name: "MainFor55S", bundle: nil)
        } else {
            storyboard = UIStoryboard(name: "MainFor4S", bundle: nil)
        }
        return storyboard
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //let storyboard: UIStoryboard = self.grabStoryBoard()
        let storyboard: UIStoryboard  = UIStoryboard(name: "Main", bundle: nil)
        self.window?.rootViewController = storyboard.instantiateInitialViewController()
        self.window!.makeKeyAndVisible()
        
        // Override point for customization after application launch.
        let colour = UIColor(red: 252/255.0, green: 212/255.0, blue: 80/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = colour
        
        UINavigationBar.appearance().barTintColor = colour
        UINavigationBar.appearance().tintColor = UIColor.black
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handledShhortcutItem = self.runShortcutItem(shortcutItem)
        completionHandler(handledShhortcutItem)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.window?.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    enum ShortcutIdentifier: String {
        case First
        case Second
        case Third
        
        init?(fullType: String)
        {
            guard let last = fullType.components(separatedBy: ".").last else {return nil}
            self.init(rawValue: last)
        }
        
        var type: String
            {
                return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
        }

    }
    
    
    func runShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool
    {
        var run = false
        
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
        guard let shortcutType = shortcutItem.type as String? else { return false }
        
        let height = UIScreen.main.bounds.size.height
        var storyboard = UIStoryboard()
        if height == 667.0 {
            storyboard = UIStoryboard(name: "Main", bundle: nil)
        } else {
            storyboard = UIStoryboard(name: "MainForPlus", bundle: nil)
        }
        
        switch (shortcutType)
        {
        case ShortcutIdentifier.First.type:
            run = true
            
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "Begin") as! UITabBarController
            
            tabBarController.selectedIndex = 1
            self.window?.rootViewController?.present(tabBarController, animated: true, completion: nil)
            
            break
        case ShortcutIdentifier.Second.type:
            run = true
            RestApiManager.sharedInstance.setsource3Dtouch(true)
            
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "Begin") as! UITabBarController
            
            tabBarController.selectedIndex = 2
            self.window?.rootViewController?.present(tabBarController, animated: true, completion: nil)
            
            break
        case ShortcutIdentifier.Third.type:
            run = true
            
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "Begin") as! UITabBarController
            
            tabBarController.selectedIndex = 3
            self.window?.rootViewController?.present(tabBarController, animated: true, completion: nil)
            
            break
        default:
            break
        }
        
        return run
        
    }
    

    
}
