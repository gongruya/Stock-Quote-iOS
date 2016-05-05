//
//  NewsFeedViewController.swift
//  Stock Quote
//
//  Created by Ruya Gong on 4/13/16.
//  Copyright © 2016 Ruya Gong. All rights reserved.
//

import UIKit

class NewsFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var stock: Stock!
    
    @IBOutlet weak var tableView: UITableView!
    
    var newsList = [News]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("News feed")
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 150;
        
        
        let query = stock.symbol.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        let url = "https://stock-handler.appspot.com?mode=news&symbol=" + query
        
        self.newsList.removeAll()
        
        let jsonData = NSData(contentsOfURL: NSURL(string: url)!)
        if jsonData == nil {
            print("Network failed")
        } else {
            let json = JSON(data: jsonData!)
            for (index: _, subJson: item) in json["d"]["results"] {
                self.newsList.append(News(json: item))
            }
        }
        
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return newsList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("NewsFeedTableViewCell") as! NewsFeedTableViewCell
        cell.titleLabel.text = newsList[indexPath.row].title
        cell.descriptionLabel.text = newsList[indexPath.row].description
        cell.sourceLabel.text = newsList[indexPath.row].source
        cell.dateLabel.text = newsList[indexPath.row].date
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let url = NSURL(string: newsList[indexPath.row].url)
        UIApplication.sharedApplication().openURL(url!)
    }
}