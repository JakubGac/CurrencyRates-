//
//  AppDelegate.swift
//  KursyWalut
//
//  Created by Jakub Gac on 11.07.2018.
//  Copyright © 2018 Jakub Gac. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FetchData().setSeconds()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (didAllow, error) in
            if !didAllow {
                print("Error, no authorization for notifications")
            }
        }
        
        FetchData().setCurrencyLimit()
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        FetchData().fetchCurrencyLimitInBackground { (status, currencyName) -> (Void) in
            if status {
                completionHandler(.newData)
                Notification().performNotification(currencyName: currencyName)
            } else {
                completionHandler(.noData)
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if let navigationController = window?.rootViewController as? UINavigationController {
            if let currencyView = navigationController.viewControllers.first as? CurrencyTableViewController {
                currencyView.viewWillAppear(true)
            }
        }
    }
}

