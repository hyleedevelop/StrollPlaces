//
//  TourSpot.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import Foundation

struct TourSpot: Codable {
    let managementNumber: String?  // 관리번호
    let name: String?              // 공원명
    let category: String?          // 공원구분
    let addressNew: String?        // 소재지 주소 (도로명)
    let addressOld: String?        // 소재지 주소 (지번)
    let lat: Double?               // 위도
    let lon: Double?               // 경도
    let areaSize: String?          // 공원면적
    let infraWorkout: String?      // 보유시설(운동시설)
    let infraPlay: String?         // 보유시설(놀이시설)
    let infraRest: String?         // 보유시설(편의시설)
    let infraFacility: String?     // 보유시설(교양시설)
    let infraEtc: String?          // 보유시설(기타시설)
    let openDate: String?          // 지정고시일
    let organization: String?      // 관리기관명
    let telephoneNumber: String?   // 전화번호
    let updateDate: String?        // 데이터기준일자
    let providerCode: String?      // 제공기관코드
    let provider: String?          // 제공기관명
    
    
}
