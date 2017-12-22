//
//  ConverterViewController.swift
//  mob-e16-ios
//
//  Created by Arnaud Duboust on 19/12/2017.
//  Copyright © 2017 Antoine Gourtay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import Firebase

class ConverterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var firstPicker: UIPickerView!
    @IBOutlet weak var secondPicker: UIPickerView!
    @IBOutlet weak var changePicker: UIButton!
    @IBOutlet weak var fieldConverted: UITextField!
    @IBOutlet weak var labelEqual: UILabel!
    @IBOutlet weak var labelConverted: UILabel!
    @IBOutlet weak var labelCurrentBalance: UILabel!
    @IBOutlet weak var buttonBuyBitcoin: UIButton!
    
    
    let keychain = KeychainSwift()
    
    var currencies = ["EUR", "USD", "GBP", "JPY", "RUB"]
    var cryptocurrencies = ["BTC", "ETH", "BCH", "LTC", "XRP"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonBuyBitcoin.layer.cornerRadius = 7
        getBalance()
        fieldConverted.keyboardType = UIKeyboardType.numberPad
        fieldConverted.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 1){
            return cryptocurrencies.count
        }else{
            return currencies.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 1){
            return cryptocurrencies[row]
        }else{
            return currencies[row]
        }
    }
    
    @IBAction func invertPressed(_ sender: UIButton) {
        let tmp = currencies
        currencies = cryptocurrencies
        cryptocurrencies = tmp
        
        let rowFirst = firstPicker.selectedRow(inComponent: 0)
        let rowSecond = secondPicker.selectedRow(inComponent: 0)
        
        firstPicker.reloadAllComponents()
        secondPicker.reloadAllComponents()
        
        firstPicker.selectRow(rowSecond, inComponent: 0, animated: false)
        secondPicker.selectRow(rowFirst, inComponent: 0, animated: false)
        
        if Float(self.fieldConverted.text!) != nil {
            callAPI()
        }else{
            self.labelConverted.text = "0"
        }
    }
    
    @IBAction func buttonBuyBitcoinPressed(_ sender: Any) {
        Analytics.logEvent("click_affiliate", parameters: [
            "fromScreen": "Convertisseur"
            ])
        UIApplication.shared.openURL(NSURL(string: "https://www.coinbase.com/buy")! as URL)
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if Float(self.fieldConverted.text!) != nil {
            callAPI()
        }else{
            self.labelConverted.text = "0"
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if Float(self.fieldConverted.text!) != nil {
            callAPI()
        }else{
            self.labelConverted.text = "0"
        }
    }
    
    func callAPI() {
        let from = cryptocurrencies[firstPicker.selectedRow(inComponent: 0)]
        let to = currencies[secondPicker.selectedRow(inComponent: 0)]
        let numberToConvert = Float(self.fieldConverted.text!)
        
        Alamofire.request("https://api.cryptonator.com/api/ticker/\(from)-\(to)").responseJSON { response in
            if let data = response.result.value {
                let json = JSON(data)
                let oneConverted = json["ticker"]["price"].floatValue
                let allConverted = oneConverted * numberToConvert!
                
                self.labelConverted.text = "\(allConverted)"
            }
        }
        Analytics.logEvent("currency_conversion", parameters: [
            "converted_from": "\(from)",
            "converted_to" : "\(to)"
            ])
    }
    
    func getBalance() {
        if let pubKey = keychain.get("pubKey"){
            Alamofire.request("https://blockexplorer.com/api/addr/\(pubKey)/balance").responseJSON { response in
                if let data = response.result.value {
                    let currentBalance = 0.00000001 * (data as! Double)
                    self.labelCurrentBalance.text = "\(currentBalance) ₿"
                }
            }
        }
    }
}

