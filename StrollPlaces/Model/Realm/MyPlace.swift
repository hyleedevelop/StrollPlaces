//
//  MyPlace.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/10.
//

import Foundation
import RealmSwift

final class MyPlace: Object {  // Object 상속 필수 ⭐️
    
    //MARK: - property
    
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var name: String
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    @Persisted var savedDate: String
    
    //MARK: - initializer
    
    convenience init(
        _id: ObjectId,
        name: String,
        latitude: Double,
        longitude: Double,
        savedDate: String
    ) {
        self.init()
        self._id = _id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.savedDate = savedDate
    }
    
    //MARK: - directly called method
    
//    func appendMyPlace(point: TrackPoint) {
//        self.points.append(point)
//    }
    
}
