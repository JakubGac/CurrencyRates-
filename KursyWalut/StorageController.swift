//
//  StorageController.swift
//  KursyWalut
//
//  Created by Jakub Gac on 11.07.2018.
//  Copyright © 2018 Jakub Gac. All rights reserved.
//

import Foundation

class StorageController {
    
    private struct Addresses {
        let nbp = "http://api.nbp.pl/api/exchangerates/tables/A"
    }
    
    func fetchCurrencies(getData: @escaping ([Currency]) -> (Void)) {
        guard let url = URL(string: Addresses().nbp) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                print("Error while creating session data Task. \(error!)")
                return
            }
            
            guard let responseData = data else {
                print("Error: did not received data")
                return
            }
            
            var results: [Currency] = []
            
            do {
                if let currencyJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String: Any]] {
                    guard let firstElement = currencyJSON.first else {
                        return
                    }
                    
                    for(key, value) in firstElement {
                        switch key {
                        case "rates":
                            if let currencies = value as? [[String: Any]] {
                                for element in currencies {
                                    guard let currency = element["currency"] as? String, let code = element["code"] as? String, let midPrice = element["mid"] as? Double else {
                                        return
                                    }
                                    results.append(Currency(currency: currency, code: code, midPrice: (midPrice*100).rounded()/100))
                                }
                            }
                            getData(results)
                            break
                        default:
                            break
                        }
                    }
                } else {
                    print("Error: couldn't fetch JSON")
                }
            } catch {
                print("Error while making JSON serialization")
                return
            }
        }
        task.resume()
    }
}

struct Currency {
    let currency: String
    let code: String
    let midPrice: Double
    
    init(currency: String, code: String, midPrice: Double) {
        self.currency = currency
        self.code = code
        self.midPrice = midPrice
    }
}
