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
    @Persisted var date: String
    @Persisted var time: String
    @Persisted var distance: Double
    
    @Persisted var name: String
    @Persisted var explanation: String
    @Persisted var feature: String
    
    //MARK: - initializer
    
    convenience init(
        points: List<TrackPoint>,
        date: String,
        time: String,
        distance: Double,
        name: String,
        explanation: String,
        feature: String
    ) {
        self.init()
        self.points = points
        self.date = date
        self.time = time
        self.distance = distance
        self.name = name
        self.explanation = explanation
        self.feature = feature
    }
    
    //MARK: - directly called method
    
    func appendTrackPoint(point: TrackPoint) {
        self.points.append(point)
    }
    
}
