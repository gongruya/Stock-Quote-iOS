//
//  StockDetailViewController.swift
//  Stock Quote
//
//  Created by Ruya Gong on 4/13/16.
//  Copyright © 2016 Ruya Gong. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit

protocol UpdateStockListDelegate: class {
    func didUpdateStockList(stock: Stock)
}

class StockDetailViewController: UIViewController, FBSDKSharingDelegate {
    
    var delegate: UpdateStockListDelegate? = nil
    var inList: Bool = false
    
    @IBOutlet weak var addFavButton: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBAction func selectView(sender: AnyObject) {
        switch sender.selectedSegmentIndex {
        case 0:
            let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StockQuoteViewController") as! StockQuoteViewController
            newViewController.stock = self.stock
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
            self.currentViewController = newViewController
        case 1:
            let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HistoryChartViewController") as! HistoryChartViewController
            newViewController.stock = self.stock
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
            self.currentViewController = newViewController
        case 2:
            let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NewsFeedViewController") as! NewsFeedViewController
            newViewController.stock = self.stock
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
            self.currentViewController = newViewController
        default:
            print("Default")
        }
    }
    
    
    @IBAction func shareStock(sender: AnyObject) {
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "http://finance.yahoo.com/q?s=" + stock.symbol)
        content.contentTitle = "Current Stock Price of " + stock.name + " is $" + String(format: "%.2f", stock.last)
        content.contentDescription = "Stock information of " + stock.name + " (" + stock.symbol + ")"
        content.imageURL = NSURL(string: "https://chart.finance.yahoo.com/t?s=" + stock.symbol + "&lang=en-US&width=505&height=250")
        
        let dialog: FBSDKShareDialog = FBSDKShareDialog()
        dialog.shareContent = content
        dialog.fromViewController = self
        /*dialog.mode = FBSDKShareDialogMode.Native
        if !dialog.canShow() {
            dialog.mode = FBSDKShareDialogMode.FeedWeb
        }*/
        dialog.mode = FBSDKShareDialogMode.FeedWeb
        dialog.delegate = self
        dialog.show()
        
    }
    internal func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("posted")
        let alertController = UIAlertController(title: "✅ Shared Successfully", message: "The stock was posted to Facebook", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    internal func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print("error")
        let alertController = UIAlertController(title: "⛔️ Error", message: "Error occurred when posting to Facebook", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    internal func sharerDidCancel(sharer: FBSDKSharing!) {
        print("cancelled")
        let alertController = UIAlertController(title: "🔴 Canceled", message: "You decided not to share the stock.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func addToFavList(sender: AnyObject) {
        if delegate != nil {
            delegate!.didUpdateStockList(self.stock)    //Add or remove stock from the list
        }
        if addFavButton.image == starEmpty {
            addFavButton.image = starFilled
        } else {
            addFavButton.image = starEmpty
        }
    }
    
    
    
    
    weak var currentViewController: UIViewController?
    
    var pageNumber: Int!
    var stock: Stock!
    
    
    let starFilled = UIImage(named: "starFilled")
    let starEmpty = UIImage(named: "starEmpty")

    override func viewDidLoad() {
        let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StockQuoteViewController") as! StockQuoteViewController
        newViewController.stock = self.stock
        self.currentViewController = newViewController
        
        self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(self.currentViewController!)
        self.addSubview(self.currentViewController!.view, toView: self.containerView)
        
        super.viewDidLoad()
        navTitle.title = stock!.symbol
        
        addFavButton.image = inList ? starFilled : starEmpty
    }
    
    
    
    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
    }
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMoveToParentViewController(nil)
        self.addChildViewController(newViewController)
        self.addSubview(newViewController.view, toView:self.containerView!)
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
            },
            completion: { finished in
                        oldViewController.view.removeFromSuperview()
                        oldViewController.removeFromParentViewController()
                        newViewController.didMoveToParentViewController(self)
        })
    }
}