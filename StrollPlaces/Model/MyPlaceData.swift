//
//  MyPlaceData.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/28.
//

import Foundation

struct MyPlaceData {
    let infoType = InfoType.marked
    let name: String
    let memo: String
    
    init(name: String, memo: String) {
        self.name = name
        self.memo = memo
    }
}
