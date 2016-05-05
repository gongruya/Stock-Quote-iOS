//
//  ViewController.swift
//  Stock Quote
//
//  Created by Ruya Gong on 4/3/16.
//  Copyright © 2016 Ruya Gong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UpdateStockListDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stockTableView: UITableView!
    
    @IBOutlet weak var autocompleteTableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var getQuoteButton: UIButton!
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    @IBOutlet weak var autorefreshSwitch: UISwitch!
    
    
    var tableEditable: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.autocompleteTableView.layer.borderWidth = 1
        self.autocompleteTableView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        self.autocompleteTableView.tableFooterView = UIView()
        self.autocompleteTableView.hidden = true
        self.loadingIndicator.hidden = true
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let symbols = userDefaults.objectForKey("favList")
        if symbols != nil {
            for e in symbols as! [String] {
                favList.append(Stock(symbol: e))
            }
        }
        refresh()
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    var favList = [Stock]()
    var suggestionList = [Stock]()
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        if tableView == self.stockTableView {
            return favList.count
        } else {
            return suggestionList.count
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == self.stockTableView {
            let cell = self.stockTableView.dequeueReusableCellWithIdentifier("StockTableViewCell") as! StockTableViewCell
            cell.name.text = favList[indexPath.row].name
            cell.symbol.text = favList[indexPath.row].symbol
            cell.cap.text = "Market Cap: " + favList[indexPath.row].cap
            cell.change.text = String(format: "%.2f", favList[indexPath.row].change) + " (\(favList[indexPath.row].changePercent))"
            if favList[indexPath.row].changeClass == "decrease" {
                cell.change.backgroundColor = UIColor.redColor()
            } else if favList[indexPath.row].changeClass == "increase" {
                cell.change.text = "+" + cell.change.text!
                cell.change.backgroundColor = UIColor(red: 0, green: 0.85, blue: 0, alpha: 1.0)
            } else {
                cell.change.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            }
            cell.price.text = String(format: "$%.2f", favList[indexPath.row].last)
            return cell
        } else {
            let cell = self.autocompleteTableView.dequeueReusableCellWithIdentifier("AutocompleteTableViewCell")! as UITableViewCell
            cell.textLabel?.text = suggestionList[indexPath.row].name + " (\(suggestionList[indexPath.row].symbol)) - " + suggestionList[indexPath.row].exchange
            return cell
        }
 
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if tableView == self.autocompleteTableView {
            self.textField.text = self.suggestionList[indexPath.row].symbol
            textField.resignFirstResponder()
            dismissAutocomplete()
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        //return !searchActive
        if tableView == self.stockTableView {
            return self.tableEditable
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.stockTableView {
            if editingStyle == UITableViewCellEditingStyle.Delete {
                favList.removeAtIndex(indexPath.row)
                self.stockTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            saveData()
        }
    }
    
    var autocompleteCounter = 0
    var lastHandled = -1
    @IBAction func autoComplete(sender: AnyObject) {
        
        if self.textField.text!.characters.count < 3 {
            dismissAutocomplete()
            return
        } else {
            autocompleteTableView.hidden = false
        }
        
        let query = self.textField.text!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        let url = "https://stock-handler.appspot.com?mode=lookup&q=" + query
        
        let currentCounter = autocompleteCounter
        autocompleteCounter += 1
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let jsonData = NSData(contentsOfURL: NSURL(string: url)!)
            if jsonData == nil {
                print("Network failed")
            } else {
                var tmpList = [Stock]()
                let json = JSON(data: jsonData!)
                if json["Message"] == nil {
                    for (index: _, subJson: item) in json {
                        let name = item["Name"].string!
                        let symbol = item["Symbol"].string!
                        let xchg = item["Exchange"].string!
                        let row = Stock(symbol: symbol, name: name, exchange: xchg)
                        tmpList.append(row)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    if currentCounter > self.lastHandled {
                        print("Query: \(query)")
                        self.lastHandled = currentCounter
                        self.suggestionList = tmpList
                        self.autocompleteTableView.reloadData()
                        if self.suggestionList.count == 0 {
                            self.autocompleteTableView.frame.size.height = 30
                            //No suggestion result
                        } else {
                            self.autocompleteTableView.frame.size.height = CGFloat((min(self.suggestionList.count, 10)) * 30)
                        }
                    }
                }
            }
        }
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let stockDetailViewController = segue.destinationViewController as! StockDetailViewController
            stockDetailViewController.delegate = self   //Hook up the delegate to update the main view
            if let selectedCell = sender as? StockTableViewCell {
                print("Fired by cell")
                textField.resignFirstResponder()
                
                var selectedStock: Stock
                let indexPath = self.stockTableView.indexPathForCell(selectedCell)!
                selectedStock = self.favList[indexPath.row]
                selectedStock.getQuote()
                stockDetailViewController.inList = favList.contains() {$0.symbol == selectedStock.symbol}
                stockDetailViewController.stock = selectedStock
            }
        }
    }
    
    
    @IBAction func getQuoteAction(sender: AnyObject) {
        textField.resignFirstResponder()
        getQuote()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        dismissAutocomplete()
        getQuote()
        return true
    }
    
    func getQuote() {
        //Fire segue mannually
        print("Fired by get quote")
        if self.textField.text == "" {
            let alertController = UIAlertController(title: "⛔️ Error", message:
                "Please enter name or symbol.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            var stock = Stock(symbol: self.textField.text!)
            stock.getQuote()
            
            if stock.failed {
                let alertController = UIAlertController(title: "⚠️ Failed to get quote", message:
                    "Invalid symbol or API server error, please type the correct symbol or select from the suggestion.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                let stockDetailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("StockDetailViewController") as! StockDetailViewController
                stockDetailViewController.delegate = self   //Hook up the delegate to update the main view
                stockDetailViewController.inList = favList.contains() {$0.symbol == stock.symbol}
                stockDetailViewController.stock = stock
                self.navigationController?.pushViewController(stockDetailViewController, animated: true)
            }
        }

    }
    
    @IBAction func refreshAction(sender: AnyObject) {
        refresh()
    }
    
    func refresh() {
        if self.favList.count == 0 {
            return
        }
        self.refreshButton.enabled = false
        self.autorefreshSwitch.enabled = false
        self.loadingIndicator.hidden = false
        self.tableEditable = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            for i in 0 ... self.favList.count - 1 {
                self.favList[i].getQuote()
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshButton.enabled = true
                self.autorefreshSwitch.enabled = true
                self.loadingIndicator.hidden = true
                self.stockTableView.reloadData()
                self.tableEditable = true
                print("Fav list updated")
            }
        }
    }
    
    var timer: NSTimer = NSTimer()
    @IBAction func autoRefresh(sender: AnyObject) {
        timer.invalidate()
        if sender.on! {
            timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector:#selector(refresh), userInfo: nil, repeats: true)
            print("Initiating autorefresh timer")
        } else {
            print("Destroying autorefresh timer")
        }
    }
    
    func dismissAutocomplete() {
        self.suggestionList.removeAll()
        self.autocompleteTableView.reloadData()
        self.autocompleteTableView.frame.size.height = 30
        self.autocompleteTableView.hidden = true
    }
    func didUpdateStockList(stock: Stock) {     //Implement the delegate
        if (favList.contains() {$0.symbol == stock.symbol}) {
            favList = favList.filter() {$0.symbol != stock.symbol}
        } else {
            favList.append(stock)
        }
        saveData()
        self.stockTableView.reloadData()
    }
    func saveData() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var symbols = [String]()
        for e in favList {
            symbols.append(e.symbol)
        }
        userDefaults.setObject(symbols, forKey: "favList")
    }
    
    
    @objc func applicationDidBecomeActive(notification: NSNotification){
        refresh()
    }
}
