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
        let seconds = UserDefaults.standard.integer(forKey: "seconds")
        if seconds == 0 {
            // defaultowo na 5 minut
            UIApplication.shared.setMinimumBackgroundFetchInterval(300)
        } else {
            UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(seconds))
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (didAllow, error) in
            if !didAllow {
                print("Error, no authorization for notifications")
            }
        }
        
        // defaultowe ustawienia dla granicznych wartości kursu, waluta SDR > 5
        if UserDefaults.standard.object(forKey: "currency") as? NSDictionary == nil {
            let dictionary: NSDictionary = [
                "currencyName": "SDR (MFW)",
                "sign": 1,
                "number": 5
            ]
            UserDefaults.standard.set(dictionary, forKey: "currency")
        }
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let currencyData = UserDefaults.standard.object(forKey: "currency") as? NSDictionary else {
            return
        }
        
        guard let currencyName = currencyData["currencyName"] as? String,
            let sign = currencyData["sign"] as? Int,
            let number = currencyData["number"] as? Double else {
                return
        }
        
        var newData = false
        var currencyNameForNotification = ""
        
        StorageController().fetchCurrencies { (data) -> (Void) in
            for element in data {
                switch sign {
                case 0:
                    if element.midPrice < number && element.currencyName == currencyName {
                        newData = true
                        currencyNameForNotification = element.currencyName
                    }
                    break
                case 1:
                    if element.midPrice > number && element.currencyName == currencyName {
                        newData = true
                        currencyNameForNotification = element.currencyName
                    }
                    break
                default:
                    break
                }
            }
            
            if newData {
                completionHandler(.newData)
                let center = UNUserNotificationCenter.current()
                let content = UNMutableNotificationContent()
                content.title = "Zmiana kursu waluty"
                content.body = "Waluta: \(currencyNameForNotification) zmieniła swój kurs"
                content.sound = UNNotificationSound.default()
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
                
                let request = UNNotificationRequest(identifier: "Notyfikacja", content: content, trigger: trigger)
                
                center.add(request) { (error) in
                    if error != nil {
                        print("error \(String(describing: error)))")
                    }
                }
            } else {
                completionHandler(.noData)
            }
        }
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if let navigationController = window?.rootViewController as? UINavigationController {
            if let currencyView = navigationController.viewControllers.first as? CurrencyTableViewController {
                currencyView.viewWillAppear(true)
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "KursyWalut")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

