//
//  RouteData.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/01.
//

import Foundation
import RealmSwift

final class TrackPoint: Object {  // Object 상속 필수 ⭐️
    
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    
    convenience init (latitude: Double, longitude: Double) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
    
}
