//
//  WalkingSpot.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import Foundation

struct WalkingSpot: Codable {
    let id: String?                // 관리번호
    let name: String?              // 명칭
    let subName: String?           // 상세명칭
    let course: String?            // 코스
    let city: String?              // 소재지
    let level: String?             // 난이도
    let lengthCategory: String?    // 코스 길이 카테고리
    let length: String?            // 코스 길이(km)
    let description: String?       // 설명
    let walkingTime: String?       // 소요시간
    let note: String?              // 주의사항
    let toiletLocation: String?    // 코스 내 화장실 위치
    let aroundInfo: String?        // 주변 정보
    let address: String?           // 소재지 주소
    let lat: Double?               // 위도
    let lon: Double?               // 경도
    
    init(id: String? = nil,
         name: String?,
         subName: String?,
         course: String? = nil,
         city: String? = nil,
         level: String? = nil,
         lengthCategory: String? = nil,
         length: String? = nil,
         description: String? = nil,
         walkingTime: String? = nil,
         note: String? = nil,
         toiletLocation: String? = nil,
         aroundInfo: String? = nil,
         address: String? = nil,
         lat: Double?,
         lon: Double?) {
        self.id = id
        self.name = name
        self.subName = subName
        self.course = course
        self.city = city
        self.level = level
        self.lengthCategory = lengthCategory
        self.length = length
        self.description = description
        self.walkingTime = walkingTime
        self.note = note
        self.toiletLocation = toiletLocation
        self.aroundInfo = aroundInfo
        self.address = address
        self.lat = lat
        self.lon = lon
    }
}
