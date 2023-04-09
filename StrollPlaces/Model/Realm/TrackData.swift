//
//  Route.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/01.
//

import Foundation
import RealmSwift

final class TrackData: Object {  // Object 상속 필수 ⭐️
    
    //MARK: - property
    
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var points: List<TrackPoint>
    @Persisted var date: Date
    @Persisted var time: String
    @Persisted var distance: Double
    @Persisted var firstLocation: String?
    @Persisted var lastLocation: String?
    
    @Persisted var name: String?
    @Persisted var explanation: String? = nil
    @Persisted var feature: String? = nil
    //@Persisted var image: UIImage? = nil
    
    
    //let points = List<TrackPoint>()
    
    //MARK: - initializer
    
    convenience init(
        points: List<TrackPoint>,
        date: Date,
        time: String,
        distance: Double,
        firstLocation: String?,
        lastLocation: String?,
        name: String?,
        explanation: String?,
        feature: String?
        //image: UIImage?
    ) {
        self.init()
        self.points = points
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
    
    //MARK: - directly called method
    
    func appendTrackPoint(point: TrackPoint) {
        self.points.append(point)
    }
    
    //MARK: - indirectly called method
    
//    private func dateToFormattedString(date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm:ss"
//        dateFormatter.locale = Locale(identifier: "ko_KR")
//
//        if let date = self.currentDate {
//            return dateFormatter.string(from: date)
//        } else {
//            return ""
//        }
//    }
    
}
