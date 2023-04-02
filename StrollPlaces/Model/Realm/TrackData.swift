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
    
    @objc dynamic var time: String?
    @objc dynamic var distance: String?
    @objc dynamic var firstLocation: String?
    @objc dynamic var lastLocation: String?
    
    @objc dynamic var name: String?
    @objc dynamic var explanation: String?
    @objc dynamic var feature: String? = nil
    //@objc dynamic var image: UIImage? = nil
    
    let points = List<TrackPoint>()
    
    convenience init(
        date: Date?,
        time: String?,
        distance: String?,
        firstLocation: String?,
        lastLocation: String?,
        name: String?,
        explanation: String?,
        feature: String?
        //image: UIImage?
    ) {
        self.init()
        self.date = date
        self.time = time
        self.distance = distance
        self.firstLocation = firstLocation
        self.lastLocation = lastLocation
        self.name = name
        self.explanation = explanation
        self.feature = feature
        //self.image = image
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
