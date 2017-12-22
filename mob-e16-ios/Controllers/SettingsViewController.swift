//
//  SettingsViewController.swift
//  mob-e16-ios
//
//  Created by Arnaud Duboust on 21/12/2017.
//  Copyright © 2017 Antoine Gourtay. All rights reserved.
//

import UIKit
import KeychainSwift
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var fieldPubKey: UITextField!
    @IBOutlet weak var buttonValidate: UIButton!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var labelError: UILabel!
    
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.setUserProperty("BTC", forName: "favorite_cryptocurrency") // ONLY BTC AVAILABLE ATM
        buttonValidate.layer.cornerRadius = 7
        buttonClose.layer.cornerRadius = 7
        self.labelError.isHidden = true
        if let pubKey = keychain.get("pubKey"){
            fieldPubKey.text = "\(pubKey)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    @IBAction func validateButtonPressed(_ sender: Any) {
        if fieldPubKey.text != "" {
            keychain.set(fieldPubKey.text!, forKey: "pubKey")
            Analytics.logEvent("key_added", parameters: [
                "key_currency": "BTC", // ONLY BTC AVAILABLE ATM
                ])
            self.dismiss(animated: true, completion: { () -> Void in
            })
        }else{
            self.labelError.isHidden = false
        }
    }
}
