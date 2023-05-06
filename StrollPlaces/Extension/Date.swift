//
//  Date.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/06.
//

import Foundation

extension Date {
    
    func getTimeIntervalString(since: Date) -> String {
        // self 시간과 since 시간의 차이(초)
        let timeIntervalInSeconds = Int(self.timeIntervalSince(since))
        
        if (0..<60) ~= timeIntervalInSeconds {
            return "방금 전"
        } else if (60..<60*60) ~= timeIntervalInSeconds {
            return "\(timeIntervalInSeconds/60)분 전"
        } else if (60*60..<60*60*24) ~= timeIntervalInSeconds {
            return "\(timeIntervalInSeconds/(60*60))시간 전"
        } else if (60*60*24..<60*60*24*7) ~= timeIntervalInSeconds {
            return "\(timeIntervalInSeconds/(60*60*24))일 전"
        } else if ((60*60*24*7)...) ~= timeIntervalInSeconds {
            return "\(timeIntervalInSeconds/(60*60*24*7))주 전"
        }
        
        return "?초 전"
    }
    
}
