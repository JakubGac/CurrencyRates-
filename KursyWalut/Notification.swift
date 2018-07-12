//
//  Notification.swift
//  KursyWalut
//
//  Created by Jakub Gac on 12.07.2018.
//  Copyright © 2018 Jakub Gac. All rights reserved.
//

import Foundation
import UserNotifications

class Notification {
    func performNotification(currencyName: String) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Zmiana kursu waluty"
        content.body = "Waluta: \(currencyName) zmieniła swój kurs"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "Notyfikacja", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if error != nil {
                print("error \(String(describing: error)))")
            }
        }
    }
}
