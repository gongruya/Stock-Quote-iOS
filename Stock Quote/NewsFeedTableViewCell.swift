//
//  NewsFeedTableViewCell.swift
//  Stock Quote
//
//  Created by Ruya Gong on 4/14/16.
//  Copyright © 2016 Ruya Gong. All rights reserved.
//

import UIKit

class NewsFeedTableViewCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}