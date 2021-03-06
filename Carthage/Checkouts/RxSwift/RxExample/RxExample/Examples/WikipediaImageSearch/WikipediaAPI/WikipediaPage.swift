//
//  WikipediaPage.swift
//  RxExample
//
//  Created by PowerMobile Team on 3/28/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

import class Foundation.NSDictionary

#if !RX_NO_MODULE
import RxSwift
#endif

struct WikipediaPage {
    let title: String
    let text: String
    
    // tedious parsing part
    static func parseJSON(_ json: NSDictionary) throws -> WikipediaPage {
        guard
            let parse = json.value(forKey: "parse"),
            let title = (parse as AnyObject).value(forKey: "title") as? String,
            let t = (parse as AnyObject).value(forKey: "text"),
            let text = (t as AnyObject).value(forKey: "*") as? String else {
            throw apiError("Error parsing page content")
        }
        
        return WikipediaPage(title: title, text: text)
    }
}
