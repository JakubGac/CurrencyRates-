//
//  CurrencyTableViewController.swift
//  KursyWalut
//
//  Created by Jakub Gac on 11.07.2018.
//  Copyright © 2018 Jakub Gac. All rights reserved.
//

import UIKit
import CoreData

class CurrencyTableViewController: UITableViewController {
    
    var listOfCurrencies: [Currency] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Kursy Walut"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        StorageController().fetchCurrencies { (data) -> (Void) in
            self.listOfCurrencies = data
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listOfCurrencies.isEmpty {
            return 1
        } else {
            return listOfCurrencies.count
        }
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath)
        if let currencyCell = cell as? CurrencyCell {
            if listOfCurrencies.isEmpty {
                currencyCell.currencyLabel.text = "Brak danych"
            } else {
                let element = listOfCurrencies[indexPath.row]
                currencyCell.model = CurrencyCell.Model(name: element.currencyName, price: String(element.midPrice), code: element.code)
            }
        }
        return cell
     }
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue" {
            if let nvc = segue.destination as? SettingsViewController {
                var listOfCurrenciesNames: [String] = []
                for element in listOfCurrencies {
                    listOfCurrenciesNames.append(element.currencyName)
                }
                nvc.listOfCurrencies = listOfCurrenciesNames
            }
        }
     }
}

class CurrencyCell: UITableViewCell {
    @IBOutlet weak var currencyLabel: UILabel!
    
    var model: Model? {
        didSet {
            guard let model = model else {
                return
            }
            currencyLabel.text = "\(model.currencyName): 1 PLN = \(model.price) \(model.code)"
        }
    }
}

extension CurrencyCell {
    struct Model {
        let currencyName: String
        let price: String
        let code: String
        
        init(name: String, price: String, code: String) {
            self.currencyName = name
            self.price = price
            self.code = code
        }
    }
}
