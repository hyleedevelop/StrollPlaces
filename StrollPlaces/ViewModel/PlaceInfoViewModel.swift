//
//  PlaceInfoViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/21.
//

import UIKit
import RxSwift

final class PlaceInfoViewModel {
    
    let pinData: PublicData
    private var titleArray = [String]()
    private var placeArray = [String]()
    
    init(_ pinData: PublicData) {
        self.pinData = pinData
    }
    
    var category: Observable<String> {
        return Observable<String>.just(pinData.category)
    }
    
    func getTitleInfo() -> Observable<[String]> {
        switch pinData.infoType {
        case .park:
            titleArray = ["명칭", "주소", "유형", "주변시설", "관리담당기관", "문의연락처"]
        case .strollWay:
            titleArray = ["명칭", "주소", "유형", "주변시설", "관리담당기관", "문의연락처"]
        case .recreationForest:
            titleArray = ["명칭", "주소", "유형", "주변시설", "관리담당기관", "문의연락처"]
        case .tourSpot:
            titleArray = ["명칭", "주소", "유형", "주변시설", "관리담당기관", "문의연락처"]
        case .marked:
            titleArray = ["명칭", "주소", "유형", "주변시설", "관리담당기관", "문의연락처"]
        }
        
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
    
    func getNumberOfItems() -> Int {
        return titleArray.count
    }
    
}
