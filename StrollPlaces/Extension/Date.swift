//
//  Date.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/06.
//

import Foundation

extension Date {
    
    // self 시간과 since 시간의 차이(초)
    func getTimeIntervalString(since target: Date) -> String {
        let timeIntervalInSeconds = Int(self.timeIntervalSince(target))
        let oneMinute = 60
        let oneHour = oneMinute*60
        let oneDay = oneHour*24
        let oneWeek = oneDay*7
        
        switch timeIntervalInSeconds {
        case 0..<oneMinute: return "방금 전"
        case oneMinute..<oneHour: return "\(timeIntervalInSeconds/oneMinute)분 전"
        case oneHour..<oneDay: return "\(timeIntervalInSeconds/oneHour)시간 전"
        case oneDay..<oneWeek: return "\(timeIntervalInSeconds/oneDay)일 전"
        case oneWeek...: return "\(timeIntervalInSeconds/oneWeek)주 전"
        default: return "알수없음"
        }
    }
    
}
