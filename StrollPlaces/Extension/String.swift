//
//  String.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/25.
//

import Foundation

extension String {
    
    // escaping string을 unescaping string으로 변환
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
    
    // string을 date로 변환
    func toDate() -> Date? {
        //"yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분 ss초"
        dateFormatter.timeZone = TimeZone(identifier: "KST")
        
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
    
}
