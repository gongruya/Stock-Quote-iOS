//
//  StockQuoteTableViewCell.swift
//  Stock Quote
//
//  Created by Ruya Gong on 4/14/16.
//  Copyright © 2016 Ruya Gong. All rights reserved.
//



import UIKit

class StockQuoteTableViewCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var tableHeader: UILabel!
    @IBOutlet weak var tableContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}