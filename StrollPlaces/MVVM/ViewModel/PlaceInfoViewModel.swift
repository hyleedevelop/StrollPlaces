//
//  PlaceInfoViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/21.
//

import UIKit
import RxSwift
import RxCocoa
import SPIndicator

final class PlaceInfoViewModel {
    
    //MARK: - normal property
    
    let itemViewModel: PublicData
    var titleArray = [String]()
    var infoArray = [String]()
    var myPlaceData = RealmService.shared.realm.objects(MyPlace.self)
    
    let checkFaveButton = BehaviorSubject<Bool>(value: false)
    
    // 현재 위치에서 멀리 떨어져있는 annotation을 선택하면 경로를 계산하는데 시간이 살짝 소요됨
    // -> 경로 계산 결과가 나오기 전까지 기본값을 먼저 label에 표출
    // -> 계산이 끝나면 didSet을 통해 새로운 label 업데이트
    var estimatedDistance = BehaviorRelay<String>(value: "거리: 계산중...")
    var estimatedTime = BehaviorRelay<String>(value: "소요시간: 계산중...")
    
    var distance: Double = -1 {
        didSet {
            if (1...) ~= self.distance {
                self.estimatedDistance.accept(
                    "거리: " + String(format: "%.1f", self.distance/1000.0) + "km"
                )
            }
            else if (0..<1) ~= self.distance {
                self.estimatedDistance.accept(
                    "거리: " + String(format: "%.1f", self.distance) + "m"
                )
            } else {
                self.estimatedDistance.accept("알수없음")
            }
        }
    }
    
    var time: Double = -1 {
        didSet {
            //let minutes = self.time.truncatingRemainder(dividingBy: 60)

            if (3600...) ~= self.time {
                let hours = self.time / 3600
                let minutes = self.time.truncatingRemainder(dividingBy: 3600) / 60
                estimatedTime.accept(
                    "소요시간: " + String(format: "%.0f", hours) + "시간 " +
                    String(format: "%.0f", minutes) + "분"
                )
            } else if (60..<3600) ~= self.time {
                let minutes = self.time / 60
                estimatedTime.accept(
                    "소요시간: " + String(format: "%.0f", minutes) + "분"
                )
            } else if (0..<60) ~= self.time {
                estimatedTime.accept("소요시간: 1분 미만")
            } else {
                estimatedTime.accept("알수없음")
            }
        }
    }
    
    var category: Observable<String> {
        return Observable<String>.just(self.itemViewModel.category)
    }
    
    //MARK: - initializer
    
    init(_ itemViewModel: PublicData) {
        self.itemViewModel = itemViewModel
        self.createPlaceInfoDictionary()
    }
    
    //MARK: - directly called method
    
    // custom modal view를 통해 제공할 정보 초기화
    func createPlaceInfoDictionary() {
        switch self.itemViewModel.infoType {
        case .park:
            self.titleArray = [
                "장소명", "유형", "주소", "참고사항", "주변시설", "관리담당", "문의연락처"
            ]
            self.infoArray = [
                itemViewModel.name, itemViewModel.category, itemViewModel.address,
                itemViewModel.feature, itemViewModel.infra, itemViewModel.organization,
                itemViewModel.telephoneNumber,
            ]
        case .strollWay:
            self.titleArray = [
                "장소명", "코스명", "코스구성", "주소", "설명", "주변시설"
            ]
            self.infoArray = [
                itemViewModel.name, itemViewModel.category, itemViewModel.route,
                itemViewModel.address, itemViewModel.feature, itemViewModel.infra,
            ]
        case .recreationForest:
            self.titleArray = [
                "장소명", "유형", "주소", "입장료", "주변시설", "관리담당", "문의연락처", "홈페이지"
            ]
            self.infoArray = [
                itemViewModel.name, itemViewModel.category, itemViewModel.address,
                itemViewModel.fee, itemViewModel.infra, itemViewModel.organization,
                itemViewModel.telephoneNumber, itemViewModel.homepage,
            ]
        //case .marked:
        }
    }
    
    // 항목 이름 얻기
    func getTitleInfo() -> Observable<[String]> {
        return Observable<[String]>.just(self.titleArray)
    }
    
    // 정보 내용 얻기
    func getSubtitleInfo() -> Observable<[String]> {
        return Observable<[String]>.just(self.infoArray)
    }
    
    // 장소 이름 얻기
    func getPlaceName() -> Observable<String> {
        return Observable<String>.just(self.itemViewModel.name)
    }
    
    // 장소 유형 얻기
    func getPlaceType() -> Observable<String> {
        var text = ""
        switch self.itemViewModel.infoType {
        case .park: text = "유형: 공원"
        case .strollWay: text = "유형: 산책로"
        case .recreationForest: text = "유형: 자연휴양림"
        }
        return Observable<String>.just(text)
    }
    
    // TableView에 표시할 정보의 개수 얻기
    func getNumberOfPlaceInfo() -> Int {
        return self.infoArray.count
    }
    
    // Realm DB에 즐겨찾기 데이터 저장하기
    func addMyPlaceData() {
        let dataToAppend = MyPlace(
            name: self.itemViewModel.name,
            category: self.itemViewModel.category,
            address: self.itemViewModel.address,
            latitude: self.itemViewModel.lat!,
            longitude: self.itemViewModel.lon!,
            infra: self.itemViewModel.infra,
            organization: self.itemViewModel.organization,
            savedDate: "\(Date())"
        )
        RealmService.shared.create(dataToAppend)
        self.checkFaveButton.onNext(true)
        
        let indicatorView = SPIndicatorView(title: "즐겨찾기 추가됨", preset: .done)
        indicatorView.present(duration: 2.0, haptic: .success)
    }
    
    // Realm DB에서 즐겨찾기 데이터 삭제하기
    func removeMyPlaceData() {
        // myPlaceData가 비어있지 않은 경우,
        // pinData의 name과 같은 name을 가지고 있는 myPlaceData 삭제
        guard self.myPlaceData.count != 0 else { return }
        
        for index in 0..<self.myPlaceData.count {
            if self.itemViewModel.name == self.myPlaceData[index].name {
                RealmService.shared.delete(self.myPlaceData[index])
                self.checkFaveButton.onNext(false)
            }
        }
        
        let indicatorView = SPIndicatorView(title: "즐겨찾기 삭제됨", preset: .done)
        indicatorView.present(duration: 2.0, haptic: .success)
    }
    
}


//MARK: - News View Model

// 뉴스 아이템(셀) 하나하나에 대한 뷰모델
final class PlaceInfoItemViewModel {
    
    let publicData: PublicData
    
    init(_ publicData: PublicData) {
        self.publicData = publicData
    }
    
}
