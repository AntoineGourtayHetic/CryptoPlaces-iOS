//
//  WalletViewController.swift
//  mob-e16-ios
//
//  Created by Arnaud Duboust on 19/12/2017.
//  Copyright © 2017 Antoine Gourtay. All rights reserved.
//

import UIKit
import Alamofire
import KeychainSwift
import SwiftyJSON
import Firebase

class WalletViewController: UIViewController {

    @IBOutlet weak var segmentedControlWallet: UISegmentedControl!
    @IBOutlet weak var navigationItemWallet: UINavigationItem!
    @IBOutlet weak var labelCurrentBalance: UILabel!
    @IBOutlet weak var labelWalletBitcoin: UILabel!
    @IBOutlet weak var labelEURWallet: UILabel!
    @IBOutlet weak var labelUSDWallet: UILabel!
    @IBOutlet weak var labelWalletTitle: UILabel!
    @IBOutlet weak var labelTransactionsTitle: UILabel!
    @IBOutlet weak var labelWalletNoKey: UILabel!
    @IBOutlet weak var buttonBuyBitcoin: UIButton!
    @IBOutlet weak var tableViewTransactions: UITableView!
    @IBOutlet weak var viewCurrencies: UIView!
    @IBOutlet weak var viewLitecoin: UIView!
    @IBOutlet weak var viewEthereum: UIView!
    @IBOutlet weak var viewBitcoin: UIView!
    
    
    
    let keychain = KeychainSwift()
    var transactionList = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewTransactions.dataSource = self as? UITableViewDataSource
        tableViewTransactions.delegate = self as? UITableViewDelegate
        buttonBuyBitcoin.layer.cornerRadius = 7
        viewLitecoin.layer.cornerRadius = 7
        viewEthereum.layer.cornerRadius = 7
        viewBitcoin.layer.cornerRadius = 7
        self.labelWalletNoKey.isHidden = true
        self.tableViewTransactions.isHidden = true
        getBalance()
        getTransactions()
    }
    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        switch segmentedControlWallet.selectedSegmentIndex {
        case 0: // Porte-feuilles
            self.labelWalletTitle.isHidden = false
            self.labelTransactionsTitle.isHidden = true
            self.labelWalletBitcoin.isHidden = false
            self.labelEURWallet.isHidden = false
            self.labelUSDWallet.isHidden = false
            self.buttonBuyBitcoin.isHidden = false
            self.tableViewTransactions.isHidden = true
            self.viewCurrencies.isHidden = false
        case 1: // Transactions
            self.tableViewTransactions.reloadData()
            self.labelWalletTitle.isHidden = true
            self.labelTransactionsTitle.isHidden = false
            self.labelWalletBitcoin.isHidden = true
            self.labelEURWallet.isHidden = true
            self.labelUSDWallet.isHidden = true
            self.buttonBuyBitcoin.isHidden = true
            self.tableViewTransactions.isHidden = false
            self.viewCurrencies.isHidden = true
        default:
            break
        }
    }
    
    @IBAction func buttonBuyBitcoinPressed(_ sender: Any) {
        Analytics.logEvent("click_affiliate", parameters: [
            "fromScreen": "Porte-feuilles"
            ])
        UIApplication.shared.openURL(NSURL(string: "https://www.coinbase.com/buy")! as URL)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getBalance() {
        if let pubKey = keychain.get("pubKey"){
            Alamofire.request("https://blockexplorer.com/api/addr/\(pubKey)/balance").responseJSON { response in
                if let data = response.result.value {
                    let currentBalance = 0.00000001 * (data as! Double)
                    self.labelCurrentBalance.text = "\(currentBalance) ₿"
                    self.labelWalletBitcoin.text = "\(currentBalance) BTC"
                    
                    Alamofire.request("https://api.cryptonator.com/api/ticker/BTC-EUR").responseJSON { response in
                        if let data = response.result.value {
                            let json = JSON(data)
                            let oneConverted = json["ticker"]["price"].floatValue
                            let allConverted = oneConverted * Float(currentBalance)
                            
                            self.labelEURWallet.text = "\(allConverted) EUR"
                        }
                    }
                    
                    Alamofire.request("https://api.cryptonator.com/api/ticker/BTC-USD").responseJSON { response in
                        if let data = response.result.value {
                            let json = JSON(data)
                            let oneConverted = json["ticker"]["price"].floatValue
                            let allConverted = oneConverted * Float(currentBalance)
                            
                            self.labelUSDWallet.text = "\(allConverted) USD"
                        }
                    }
                }
            }
        }else{
            self.labelWalletNoKey.isHidden = false
            self.labelWalletBitcoin.text = "0 BTC"
            self.labelEURWallet.text = "0 EUR"
            self.labelUSDWallet.text = "0 USD"
        }
    }
    
    func getTransactions() {
        if let pubKey = keychain.get("pubKey"){
            Alamofire.request("https://blockexplorer.com/api/txs/?address=\(pubKey)").responseJSON { response in
                if let data = response.result.value {
                    let json = JSON(data)
                    for (_,subJson):(String, JSON) in json["txs"] {
                        var value = subJson["vin"][0]["value"]
                        let adress = subJson["vin"][0]["addr"]
                        var confirmations = subJson["confirmations"]
                        let transaction = Transaction(value: value.floatValue, received: true, adress: "\(adress)", confirmations: Int(confirmations.floatValue), date: Date(timeIntervalSince1970: TimeInterval(subJson["time"].floatValue)))
                        self.transactionList.append(transaction)
                    }
                }
            }
        }
    }
}

extension WalletViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell")
        if let transactionCell = cell as? TransactionTableViewCell {
            
            let index = indexPath.row
            let transaction = self.transactionList[index]
            
            transactionCell.setup(withTheTransaction: transaction)
            
            return transactionCell
        }
        
        return UITableViewCell()
    }
}


extension WalletViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let index = indexPath.row
        _ = self.transactionList[index]        
    }
    
}
