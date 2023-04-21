//
//  RouteData.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/01.
//

import Foundation
import RealmSwift

final class TrackPoint: Object {  // Object 상속 필수 ⭐️
    
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    @Persisted var id: String
    
    convenience init (latitude: Double, longitude: Double, id: String) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
        self.id = id
    }
    
}
