//
//  SecOnboardingViewController.swift
//  mob-e16-ios
//
//  Created by Arnaud Duboust on 20/12/2017.
//  Copyright © 2017 Antoine Gourtay. All rights reserved.
//

import UIKit
import KeychainSwift

class SecOnboardingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var fieldKeyOnboarding: UITextField!
    @IBOutlet weak var pickerOnboarding: UIPickerView!
    @IBOutlet weak var buttonStartOnboarding: UIButton!
    @IBOutlet weak var buttonSkipOnboarding: UIButton!
    @IBOutlet weak var labelErrorOnboarding: UILabel!
    
    var cryptocurrencies = ["BTC", "ETH", "BCH", "LTC", "XRP"]
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelErrorOnboarding.isHidden = true
        buttonStartOnboarding.layer.cornerRadius = 7
    }
    
    @IBAction func buttonStartPressed(_ sender: Any) {
        if fieldKeyOnboarding.text == "" {
            labelErrorOnboarding.isHidden = false
        }else{
            keychain.set(fieldKeyOnboarding.text!, forKey: "pubKey")
            keychain.set(cryptocurrencies[pickerOnboarding.selectedRow(inComponent: 0)], forKey: "crypto1")
            keychain.set(true, forKey: "onboardingPassed")
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! UITabBarController
            self.present(nextViewController, animated:true, completion:nil)
        }
    }
    
    @IBAction func buttonSkipPressed(_ sender: Any) {
        keychain.set(true, forKey: "onboardingPassed")
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! UITabBarController
        self.present(nextViewController, animated:true, completion:nil)
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cryptocurrencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cryptocurrencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let str = cryptocurrencies[row]
        return NSAttributedString(string: str, attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
