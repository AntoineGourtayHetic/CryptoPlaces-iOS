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

class WalletViewController: UIViewController {

    @IBOutlet weak var segmentedControlWallet: UISegmentedControl!
    @IBOutlet weak var navigationItemWallet: UINavigationItem!
    @IBOutlet weak var labelCurrentBalance: UILabel!
    @IBOutlet weak var labelWalletBitcoin: UILabel!
    @IBOutlet weak var labelEURWallet: UILabel!
    @IBOutlet weak var labelUSDWallet: UILabel!
    @IBOutlet weak var labelWalletTitle: UILabel!
    @IBOutlet weak var labelWalletNoKey: UILabel!
    @IBOutlet weak var tableViewTransactions: UITableView!
    
    
    
    let keychain = KeychainSwift()
    var transactionList = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewTransactions.dataSource = self as? UITableViewDataSource
        tableViewTransactions.delegate = self as? UITableViewDelegate
        self.labelWalletNoKey.isHidden = true
        self.tableViewTransactions.isHidden = true
        getBalance()
        
        let unixtimeInterval = 1513804098
        
        var transaction = Transaction(value: 0.123456, received: true, adress: "1ArkBmF32gUXt5cEmc48nHhFBnY3c1yH1V", confirmations: 6, date: Date(timeIntervalSince1970: TimeInterval(unixtimeInterval)))
        self.transactionList.append(transaction)
        
        var transaction2 = Transaction(value: 2.123456, received: true, adress: "1ArkBmF32gUXt5cEmc48nHhFBnY3c1yH1V", confirmations: 6, date: Date(timeIntervalSince1970: TimeInterval(unixtimeInterval)))
        self.transactionList.append(transaction2)
        
        var transaction3 = Transaction(value: 4.123456, received: true, adress: "1ArkBmF32gUXt5cEmc48nHhFBnY3c1yH1V", confirmations: 6, date: Date(timeIntervalSince1970: TimeInterval(unixtimeInterval)))
        self.transactionList.append(transaction3)
        
        print(transactionList)
    }
    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        switch segmentedControlWallet.selectedSegmentIndex {
        case 0: // Porte-feuilles
            self.labelWalletTitle.text = "Mon porte-feuilles Bitcoin"
            self.labelWalletBitcoin.isHidden = false
            self.labelEURWallet.isHidden = false
            self.labelUSDWallet.isHidden = false
            self.tableViewTransactions.isHidden = true
        case 1: // Transactions
            self.labelWalletTitle.text = "Mes transactions"
            self.labelWalletBitcoin.isHidden = true
            self.labelEURWallet.isHidden = true
            self.labelUSDWallet.isHidden = true
            self.tableViewTransactions.isHidden = false
        default:
            break
        }
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
        // Deselection la cellule car ce n'est pas automatique
        tableView.deselectRow(at: indexPath, animated: false)
        
        let index = indexPath.row
        let transaction = self.transactionList[index]
        
        
        // Crée un alerte controlleur vide
        // let alertController = UIAlertController(title: "Tap sur serie", message: serie.title, preferredStyle: .alert)
        
        // Ajout de l'action cancel, pour pouvoir fermer la popup
        // let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        // alertController.addAction(actionCancel)
        
        // Affiche la popup
        // self.present(alertController, animated: true)
        
    }
    
}
