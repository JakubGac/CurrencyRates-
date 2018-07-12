//
//  FetchData.swift
//  KursyWalut
//
//  Created by Jakub Gac on 12.07.2018.
//  Copyright © 2018 Jakub Gac. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class FetchData {
    func setSeconds() {
        let seconds = UserDefaults.standard.integer(forKey: DictionaryKeys.secondsDictionaryKey.name())
        if seconds == 0 {
            UIApplication.shared.setMinimumBackgroundFetchInterval(300)
        } else {
            UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(seconds))
        }
    }
    
    func setCurrencyLimit() {
        if UserDefaults.standard.object(forKey: DictionaryKeys.currencyDictionaryKey.name()) as? NSDictionary == nil {
            let dictionary: NSDictionary = [
                DictionaryKeys.currencyName.name(): "SDR (MFW)",
                DictionaryKeys.limitSign.name(): 1,
                DictionaryKeys.limitValue.name(): 5
            ]
            UserDefaults.standard.set(dictionary, forKey: DictionaryKeys.currencyDictionaryKey.name())
        }
    }
    
    func fetchCurrencyLimitInBackground(newData: @escaping (Bool, String) -> (Void)) {
        guard let currencyData = UserDefaults.standard.object(forKey: DictionaryKeys.currencyDictionaryKey.name()) as? NSDictionary else {
            return
        }
        
        guard let currencyName = currencyData[DictionaryKeys.currencyName.name()] as? String,
            let sign = currencyData[DictionaryKeys.limitSign.name()] as? Int,
            let number = currencyData[DictionaryKeys.limitValue.name()] as? Double else {
                return
        }
        
        StorageController().fetchCurrencies { (data) -> (Void) in
            for element in data {
                switch sign {
                case 0:
                    if element.midPrice < number && element.currencyName == currencyName {
                        newData(true, element.currencyName)
                    }
                    break
                case 1:
                    if element.midPrice > number && element.currencyName == currencyName {
                        newData(true, element.currencyName)
                    }
                    break
                default:
                    break
                }
            }
        }
    }
}


