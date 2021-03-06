//
//  WikipediaSearchResult.swift
//  RxExample
//
//  Created by PowerMobile Team on 3/28/15.
//  Copyright © 2015 PowerMobile Team. All rights reserved.
//

#if !RX_NO_MODULE
import RxSwift
#endif

import struct Foundation.URL

struct WikipediaSearchResult: CustomDebugStringConvertible {
    let title: String
    let description: String
    let URL: Foundation.URL

    // tedious parsing part
    static func parseJSON(_ json: [AnyObject]) throws -> [WikipediaSearchResult] {
        let rootArrayTyped: [[AnyObject]] = json.flatMap { $0 as? [AnyObject] }
        
        guard rootArrayTyped.count == 3 else {
            throw WikipediaParseError
        }
        
        let (titles, descriptions, urls) = (rootArrayTyped[0], rootArrayTyped[1], rootArrayTyped[2])

        let titleDescriptionAndUrl: [((AnyObject, AnyObject), AnyObject)] = Array(zip(zip(titles, descriptions), urls))
        
        return try titleDescriptionAndUrl.map { result -> WikipediaSearchResult in
            let ((title, description), url) = result

            guard let titleString = title as? String,
                  let descriptionString = description as? String,
                  let urlString = url as? String,
                  let URL = Foundation.URL(string: urlString) else {
                throw WikipediaParseError
            }

            return WikipediaSearchResult(title: titleString, description: descriptionString, URL: URL)
        }
    }
}

extension WikipediaSearchResult {
    var debugDescription: String {
        return "[\(title)](\(URL))"
    }
}
