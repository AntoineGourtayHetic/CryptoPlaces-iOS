//
//  SettingsViewController.swift
//  mob-e16-ios
//
//  Created by Arnaud Duboust on 21/12/2017.
//  Copyright © 2017 Antoine Gourtay. All rights reserved.
//

import UIKit
import KeychainSwift

class SettingsViewController: UIViewController {

    @IBOutlet weak var fieldPubKey: UITextField!
    @IBOutlet weak var buttonValidate: UIButton!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var labelError: UILabel!
    
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelError.isHidden = true
        if let pubKey = keychain.get("pubKey"){
            fieldPubKey.text = "\(pubKey)"
        }
        // Do any additional setup after loading the view.
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
            self.dismiss(animated: true, completion: { () -> Void in
            })
        }else{
            self.labelError.isHidden = false
        }
    }
}
