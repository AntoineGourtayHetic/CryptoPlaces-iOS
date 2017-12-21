//
//  Transaction.swift
//  mob-e16-ios
//
//  Created by Arnaud Duboust on 21/12/2017.
//  Copyright © 2017 Antoine Gourtay. All rights reserved.
//

import Foundation

class Transaction {
    let value: Float
    let received: Bool
    let adress: String
    let confirmations: Int
    let date: Date
    
    init(value newValue: Float, received newReceived: Bool, adress newAdress: String, confirmations newConfirmations: Int, date newDate: Date) {
        self.value = newValue
        self.received = newReceived
        self.adress = newAdress
        self.confirmations = newConfirmations
        self.date = newDate
    }
}
