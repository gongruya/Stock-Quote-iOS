//
//  Stock.swift
//  Stock Quote
//
//  Created by Ruya Gong on 4/12/16.
//  Copyright © 2016 Ruya Gong. All rights reserved.
//

import Foundation

struct Stock {
    var symbol: String = ""
    var name: String = ""
    var exchange: String = ""
    var last: Double = 0
    var change: Double = 0
    var changePercent: String = ""
    var time: String = ""
    var cap: String = ""
    var volume: String = ""
    var changeYTD: Double = 0
    var YTDPercent: String = ""
    var high: Double = 0
    var low: Double = 0
    var open: Double = 0
    var failed: Bool = false
    var changeClass: String = ""
    var YTDClass: String = ""
    
    init() {}
    init(symbol: String) {
        //Only set up symbol
        self.symbol = symbol
    }
    init(symbol: String, name: String, exchange: String) {
        //The lookup API
        self.name = name
        self.symbol = symbol
        self.exchange = exchange
    }
    init(json: JSON) {
        symbol = json["Symbol"].string!
        name = json["Name"].string!
        last = json["Last"].doubleValue
        change = json["Change"].doubleValue
        changePercent = json["ChangePercent"].string!
        time = json["Time"].string!
        cap = json["Cap"].string!
        volume = json["Volume"].string!
        changeYTD = json["ChangeYTD"].doubleValue
        YTDPercent = json["YTDPercent"].string!
        high = json["High"].doubleValue
        low = json["Low"].doubleValue
        open = json["Open"].doubleValue
        changeClass = json["ChangeClass"].string!
        YTDClass = json["YTDClass"].string!
    }
    mutating func getQuote() {
        let query = symbol.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        let url = "https://stock-handler.appspot.com?mode=quote&symbol=" + query! + "&timeformat=M%20j%20Y,%20g:i%20a"
        let jsonData = NSData(contentsOfURL: NSURL(string: url)!)
        if jsonData == nil {
            print("Network failed")
            failed = true
        } else {
            let json = JSON(data: jsonData!)
            if json.count != 0 {
                let updated = Stock(json: json)
                if (updated.name == "API error") {
                    print("API error")
                    failed = true
                } else {
                    self = updated
                    print("update " + self.symbol)
                    failed = false
                }
            } else {
                print("Invalid symbol")
                failed = true
            }
        }
    }
}