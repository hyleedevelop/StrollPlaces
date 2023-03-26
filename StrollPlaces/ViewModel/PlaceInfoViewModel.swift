//
//  PlaceInfoViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/21.
//

import UIKit
import RxSwift
import RxCocoa

final class PlaceInfoViewModel {
    
    //MARK: - 저장속성
    
    let pinData: PublicData
    private var titleArray = [String]()
    private var placeArray = [String]()
    let numberOfItems = BehaviorSubject<Int>(value: 5)
    
    // 현재 위치에서 멀리 떨어져있는 annotation을 선택하면 경로를 계산하는데 시간이 살짝 소요됨
    // -> 결과가 나오기 전까지 기본값을 먼저 label에 표출
    // -> 계산이 끝나면 didSet을 통해 새로운 label 업데이트
    var estimatedDistance = BehaviorRelay<String>(value: "거리: 계산중...")
    var estimatedTime = BehaviorRelay<String>(value: "소요시간: 계산중...")
    
    //MARK: - 계산속성
    
    var distance: Double = -1 {
        didSet {
            if (1...) ~= self.distance {
                estimatedDistance.accept("거리: " +
                                         String(format: "%.1f", self.distance/1000.0) +
                                         "km")
            }
            else if (0..<1) ~= self.distance {
                estimatedDistance.accept("거리: " +
                                         String(format: "%.1f", self.distance) +
                                         "m")
            } else {
                estimatedDistance.accept("알수없음")
            }
        }
    }
    
    var time: Double = -1 {
        didSet {
            //let minutes = self.time.truncatingRemainder(dividingBy: 60)

            if (3600...) ~= self.time {
                let hours = self.time / 3600
                let minutes = self.time.truncatingRemainder(dividingBy: 3600) / 60
                estimatedTime.accept("소요시간: " +
                                     String(format: "%.0f", hours) +
                                     "시간 " +
                                     String(format: "%.0f", minutes) +
                                     "분")
            } else if (60..<3600) ~= self.time {
                let minutes = self.time / 60
                estimatedTime.accept("소요시간: " +
                                     String(format: "%.0f", minutes) +
                                     "분")
            } else if (0..<60) ~= self.time {
                estimatedTime.accept("소요시간: 1분 미만")
            } else {
                estimatedTime.accept("알수없음")
            }
        }
    }
    
    var category: Observable<String> {
        return Observable<String>.just(pinData.category)
    }
    
    //MARK: - 생성자
    
    init(_ pinData: PublicData) {
        self.pinData = pinData
    }
    
    //MARK: - 메서드

    @discardableResult
    func getTitleInfo() -> Observable<[String]> {
        switch pinData.infoType {
        case .park:
            titleArray = ["장소명", "주소", "유형", "주변시설", "관리담당기관", "문의연락처"]
        case .strollWay:
            titleArray = ["장소명", "주소", "유형", "주변시설", "관리담당기관", "문의연락처"]
        case .recreationForest:
            titleArray = ["장소명", "주소", "유형", "주변시설", "관리담당기관", "문의연락처"]
        case .tourSpot:
            titleArray = ["장소명", "주소", "유형", "주변시설", "관리담당기관", "문의연락처"]
        case .marked:
            titleArray = ["장소명", "주소", "유형", "주변시설", "관리담당기관", "문의연락처"]
        }
        
        self.numberOfItems.onNext(titleArray.count)
        return Observable<[String]>.just(titleArray)
    }
    
    func getPlaceInfo() -> Observable<[String]> {
        switch pinData.infoType {
        case .park:
            placeArray = [pinData.name, pinData.address,
                          pinData.category, pinData.infra,
                          pinData.organization, pinData.telephoneNumber]
        case .strollWay:
            placeArray = [pinData.name, pinData.address,
                          pinData.category, pinData.infra,
                          pinData.organization, pinData.telephoneNumber]
        case .recreationForest:
            placeArray = [pinData.name, pinData.address,
                          pinData.category, pinData.infra,
                          pinData.organization, pinData.telephoneNumber]
        case .tourSpot:
            placeArray = [pinData.name, pinData.address,
                          pinData.category, pinData.infra,
                          pinData.organization, pinData.telephoneNumber]
        case .marked:
            placeArray = [pinData.name, pinData.address,
                          pinData.category, pinData.infra,
                          pinData.organization, pinData.telephoneNumber]
        }
        
        return Observable<[String]>.just(placeArray)
    }
    
    func getPlaceType() -> Observable<InfoType> {
        return Observable<InfoType>.just(pinData.infoType)
    }
    
}
