//
//  SettingsViewController.swift
//  KursyWalut
//
//  Created by Jakub Gac on 12.07.2018.
//  Copyright © 2018 Jakub Gac. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    var listOfCurrencies: [String] = [] {
        didSet {
            if view.window != nil {
                pickerView.reloadAllComponents()
            }
        }
    }
    private var pickedRow = 0
    
    override func viewDidLoad() {
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var saveSecondsTextField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var currencyTextFIeld: UITextField!
    
    @IBAction func saveSecondsButton(_ sender: UIButton) {
        if let text = saveSecondsTextField.text {
            if text.isNumber {
                let number = Int(text)!
                if number > 0 {
                    UserDefaults.standard.set(number, forKey: DictionaryKeys.secondsDictionaryKey.name())
                    popsTheAlert(title: "OK", message: "Zapisano prawidłowo")
                } else {
                    popsTheAlert(title: "Błąd", message: "Wprowadziłeś niepoprawną liczbę")
                }
            } else {
                popsTheAlert(title: "", message: "Miałeś wprowadzić liczbę a wprowadzasz litery? ;) ")
            }
        }
    }
    
    
    @IBAction func saveCurrencyButton(_ sender: UIButton) {
        if let text = currencyTextFIeld.text {
            if text.isNumber {
                let number = Double(text)!
                if number > 0 {
                    let dictionary: NSDictionary = [
                        DictionaryKeys.currencyName.name(): (listOfCurrencies[pickedRow]),
                        DictionaryKeys.limitSign.name(): segmentedControl.selectedSegmentIndex,
                        DictionaryKeys.limitValue.name(): number
                    ]
                    UserDefaults.standard.set(dictionary, forKey: DictionaryKeys.currencyDictionaryKey.name())
                    popsTheAlert(title: "OK", message: "Zapisano prawidłowo")
                } else {
                    popsTheAlert(title: "Błąd", message: "Wprowadziłeś niepoprawną liczbę")
                }
            } else {
                popsTheAlert(title: "", message: "Miałeś wprowadzić liczbę a wprowadzasz litery? ;) ")
            }
        }
    }
    
    // Mark: - Delegates
    // picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listOfCurrencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return listOfCurrencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickedRow = row
    }
}

extension String  {
    var isNumber: Bool {
        return Double(self) != nil
    }
}

extension UIViewController {
    func popsTheAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
