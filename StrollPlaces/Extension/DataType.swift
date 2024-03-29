//
//  Double.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import Foundation

//MARK: - extension for Double

extension Double {
    
    var m: Double {
        return self
    }
    
    var km: Double {
        return (self * 1000)
    }
    
    var minute: Double {
        return (self / 60.0)
    }
    
}

//MARK: - extension for String

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
    func toDate(mode: DateFormatType) -> Date? {
        switch mode {
        case .myPlace:  // ex) "yyyy-MM-dd HH:mm:ss"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분 ss초"
            dateFormatter.timeZone = TimeZone(identifier: "KST")
            
            if let date = dateFormatter.date(from: self) {
                return date
            } else {
                return nil
            }
        case .news:  // ex) "Sun, 07 May 2023 12:35:00"
            let newSelf = String(self.prefix(25))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.timeZone = TimeZone(identifier: "KST")
            
            if let date = dateFormatter.date(from: newSelf) {
                return date
            } else {
                return nil
            }
        }
    }
    
    // string을 URLrequest 구조체로 변환
    func toURLRequest() -> URLRequest {
        let urlStringEncoded: String = self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let queryURL: URL = URL(string: urlStringEncoded)!
        var urlRequest = URLRequest(url: queryURL)
        
        urlRequest.addValue(K.News.naverClientID, forHTTPHeaderField: "X-Naver-Client-Id")
        urlRequest.addValue(K.News.naverClientKEY, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        return urlRequest
    }
    
}
