//
//  News.swift
//  Stock Quote
//
//  Created by Ruya Gong on 4/14/16.
//  Copyright © 2016 Ruya Gong. All rights reserved.
//

import Foundation

struct News {
    var title: String = ""
    var url: String = ""
    var description: String = ""
    var source: String = ""
    var date: String = ""
    init() {}
    init(json: JSON) {
        title = json["Title"].string!
        url = json["Url"].string!
        description = json["Description"].string!
        source = json["Source"].string!
        date = json["Date"].string!
    }
}