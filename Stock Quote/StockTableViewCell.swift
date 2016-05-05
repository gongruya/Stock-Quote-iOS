//
//  StockTableViewCell.swift
//  Stock Quote
//
//  Created by Ruya Gong on 4/13/16.
//  Copyright © 2016 Ruya Gong. All rights reserved.
//

import UIKit

class StockTableViewCell: UITableViewCell {
    // MARK: Properties
    
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var cap: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}