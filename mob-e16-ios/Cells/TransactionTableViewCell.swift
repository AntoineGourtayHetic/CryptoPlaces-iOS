//
//  TransactionTableViewCell.swift
//  mob-e16-ios
//
//  Created by Arnaud Duboust on 21/12/2017.
//  Copyright © 2017 Antoine Gourtay. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateTransaction: UILabel!
    @IBOutlet weak var amountTransaction: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(withTheTransaction transaction: Transaction) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let strDate = dateFormatter.string(from: transaction.date)
        
        self.dateTransaction.text = "\(strDate)"
        self.amountTransaction.text = "\(transaction.value) BTC"
    }

}

