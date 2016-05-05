//
//  StockQuoteChartTableViewCell.swift
//  Stock Quote
//
//  Created by Ruya Gong on 4/14/16.
//  Copyright © 2016 Ruya Gong. All rights reserved.
//

import UIKit

class StockQuoteChartTableViewCell: UITableViewCell {
    // MARK: Properties
    
    @IBOutlet weak var stockChartImageView: GSSimpleImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}