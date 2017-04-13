//
//  String+extension.swift
//  operation-queue-ios
//
//  Created by Ramunas Jurgilas on 2017-04-11.
//  Copyright © 2017 Ramūnas Jurgilas. All rights reserved.
//

import Foundation

extension String {
    func countKeywords(_ keywords: [String]) -> [String : Int] {
        var result = [String: Int]()
        keywords.forEach() {
            let regexPattern = "(?<![wd])\($0)(?![wd])"
            let regex = try? NSRegularExpression(pattern: regexPattern,
                                                 options: .caseInsensitive)
            let matches = regex?.matches(in: self,
                                         range: NSMakeRange(0, self.characters.count))
            
            result[$0] = (matches?.count ?? 0)
        }
        return result
    }
    
    func removeKeywords(_ keywords: [String]) -> String {
        var result = self
        keywords.forEach() {
            result = result.replacingOccurrences(of: $0, with: "")
        }
        return result
    }
}
