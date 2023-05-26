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
    
    @Persisted var pinNumber: Int
    @Persisted var saveDate: String
    
    //MARK: - initializer
    
    convenience init(
        pinNumber: Int,
        saveDate: String
    ) {
        self.init()
        self.pinNumber = pinNumber
        self.saveDate = saveDate
    }
    
}
