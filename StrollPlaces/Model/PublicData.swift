//
//  Park.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import Foundation

struct PublicData {
    let infoType: InfoType       // 데이터 타입(열거형)
    let name: String             // 명칭
    let category: String         // 장소 구분
    let route: String            // 경로
    let address: String          // 소재지 주소 (지번)
    let lat: Double?             // 위도
    let lon: Double?             // 경도
    let feature: String          // 참고사항
    let infra: String            // 주변시설
    let organization: String     // 관리기관명
    let telephoneNumber: String  // 전화번호
    let homepage: String         // 웹사이트 주소
    let fee: String              // 입장료
    
    init(
        infoType: InfoType,
        name: String,
        category: String,
        route: String,
        address: String,
        lat: Double,
        lon: Double,
        feature: String,
        infra: String,
        organization: String,
        telephoneNumber: String,
        homepage: String,
        fee: String
    ) {
        self.infoType = infoType
        self.name = name
        self.category = category
        self.route = route
        self.address = address
        self.lat = lat
        self.lon = lon
        self.feature = feature
        self.infra = infra
        self.organization = organization
        self.telephoneNumber = telephoneNumber
        self.homepage = homepage
        self.fee = fee
    }
}
