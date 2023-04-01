//
//  Route.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/01.
//

import Foundation
import RealmSwift

final class TrackData: Object {  // Object 상속 필수 ⭐️
    
    @objc dynamic var date: Date? = nil
    
    let points = List<TrackPoint>()
    
    convenience init(date: Date?) {
        self.init()
        self.date = date
    }
    
    func appendTrackPoint(point: TrackPoint) {
        self.points.append(point)
    }
    
    func dateToFormattedString() -> String {
        if let date = self.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            dateFormatter.locale = Locale(identifier: "ko_KR")
            return dateFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
}
