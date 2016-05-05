//
//  HistoryChartViewController.swift
//  Stock Quote
//
//  Created by Ruya Gong on 4/13/16.
//  Copyright © 2016 Ruya Gong. All rights reserved.
//

import UIKit

class HistoryChartViewController: UIViewController, UIWebViewDelegate {
    var stock: Stock!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("History chart")
        
        self.webView.scrollView.bounces = false
        self.webView.scrollView.scrollEnabled = false
        
        let url = NSBundle.mainBundle().URLForResource("chart", withExtension: "html")
        let realURL = (url?.absoluteString)! + "#\(stock.symbol.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!)"
        let myURL = NSURL(string: realURL)
        let requestObj = NSURLRequest(URL: myURL!)
        self.webView.loadRequest(requestObj)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("Finished loading chart")
        //webView.stringByEvaluatingJavaScriptFromString("window.location.href='#hashtag';")
    }

}