//
//  Park.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import Foundation

struct PublicData {
    let infoType: InfoType       // 데이터 타입(열거형)
    let name: String             // 공원명
    let category: String         // 공원구분
    let address: String          // 소재지 주소 (지번)
    let lat: Double?             // 위도
    let lon: Double?             // 경도
    let infra: String            // 주변시설
    let organization: String     // 관리기관명
    let telephoneNumber: String  // 전화번호
    
    init(infoType: InfoType,
         name: String,
         category: String,
         address: String,
         lat: Double,
         lon: Double,
         infra: String,
         organization: String,
         telephoneNumber: String) {
        self.infoType = infoType
        self.name = name
        self.category = category
        self.address = address
        self.lat = lat
        self.lon = lon
        self.infra = infra
        self.organization = organization
        self.telephoneNumber = telephoneNumber
    }
}
