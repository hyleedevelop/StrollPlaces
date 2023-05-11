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
    @Persisted var category: String
    @Persisted var address: String
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    @Persisted var infra: String
    @Persisted var organization: String
    @Persisted var savedDate: String
    
    //MARK: - initializer
    
    convenience init(
        name: String,
        category: String,
        address: String,
        latitude: Double,
        longitude: Double,
        infra: String,
        organization: String,
        savedDate: String
    ) {
        self.init()
        self.name = name
        self.category = category
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.infra = infra
        self.organization = organization
        self.savedDate = savedDate
    }
    
    //MARK: - directly called method
    
//    func appendMyPlace(point: TrackPoint) {
//        self.points.append(point)
//    }
    
}
