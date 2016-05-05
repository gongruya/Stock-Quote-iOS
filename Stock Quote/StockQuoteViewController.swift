//
//  StockQuoteViewController.swift
//  Stock Quote
//
//  Created by Ruya Gong on 4/13/16.
//  Copyright © 2016 Ruya Gong. All rights reserved.
//

import UIKit

class StockQuoteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var stock: Stock!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.allowsSelection = false
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 400;
        print("Stock detail")
        tableContent = [stock.name, stock.symbol, String(format: "$%.2f", stock.last), (stock.changeClass == "increase" ? "+" : "") + String(format: "%.2f", stock.change) + " (\(stock.changePercent))", stock.time, stock.cap, stock.volume, String(format: "%.2f", stock.changeYTD) + " (\(stock.YTDPercent))", String(format: "$%.2f", stock.high), String(format: "$%.2f", stock.low), String(format: "$%.2f", stock.open)]
    }
    
    let tableHeader = ["Name", "Symbol", "Last Price", "Change", "Time and Date", "Market Cap", "Volume", "Change YTD", "High Price", "Low Price", "Opening Price"]
    var tableContent = [String]()
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let rows = [11, 1]
        return rows[section]
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        if indexPath.section == 0 {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("StockQuoteTableViewCell") as! StockQuoteTableViewCell
            cell.tableHeader.text = self.tableHeader[indexPath.row]
            //cell.tableContent.text = self.tableContent[indexPath.row]
            
            let attrContent = NSMutableAttributedString(string: self.tableContent[indexPath.row])
            
            let downArrow = NSMutableAttributedString(string: " ➘", attributes: [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 17)!])
            let upArrow = NSMutableAttributedString(string: " ➚", attributes: [NSForegroundColorAttributeName: UIColor.greenColor(), NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 17)!])
            
            if self.tableHeader[indexPath.row] == "Change" {
                if self.stock.changeClass == "increase" {
                    attrContent.appendAttributedString(upArrow)
                } else if self.stock.changeClass == "decrease" {
                    attrContent.appendAttributedString(downArrow)
                }
            } else if self.tableHeader[indexPath.row] == "Change YTD" {
                if self.stock.YTDClass == "increase" {
                    attrContent.appendAttributedString(upArrow)
                } else if self.stock.YTDClass == "decrease" {
                    attrContent.appendAttributedString(downArrow)
                }
            }
            cell.tableContent.attributedText = attrContent
            
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("StockQuoteChartTableViewCell") as! StockQuoteChartTableViewCell
            
            let url = NSURL(string: "https://chart.finance.yahoo.com/t?s=" + stock.symbol.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())! + "&lang=en-US&width=400&height=400")
            cell.stockChartImageView.HDUrl = NSURL(string: "https://chart.finance.yahoo.com/t?s=" + stock.symbol.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())! + "&lang=en-US&width=765&height=765")
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                if data == nil {
                    print("Network failed")
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        let theImage = UIImage(data: data!)
                        cell.stockChartImageView.image = theImage
                    }
                }
            }
            
            //print(cell.frame.size.width)
            //cell.frame.size.height = cell.frame.size.width
            return cell
        }
    }
    
}