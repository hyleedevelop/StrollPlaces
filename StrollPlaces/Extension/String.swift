//
//  String.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/25.
//

import Foundation

extension String {
    
    func unescape() -> String {
        let characters = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&apos;": "'",
            "<b>": "",
            "</b>": ""
        ]
        
        var str = self
        for (escaped, unescaped) in characters {
            str = str.replacingOccurrences(
                of: escaped, with: unescaped, options: NSString.CompareOptions.literal, range: nil
            )
        }
        
        return str
    }
    
    func convertDateString() -> String {
        let convertedString = ""
        return convertedString
    }
    
}
