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
    
    //MARK: - 생성자 관련
    
    // 초기화가 필요한 속성
    let itemViewModel: PublicData
    var pinNumber: Int
    
    // 초기생성자
    init(_ itemViewModel: PublicData, pinNumber: Int) {
        self.itemViewModel = itemViewModel
        self.pinNumber = pinNumber
        self.createPlaceInfoDictionary()
    }
    
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
        case .marked:
            self.titleArray = []
            self.infoArray = []
        }
    }
    
    //MARK: - 일반 변수
    
    var titleArray = [String]()
    var infoArray = [String]()
    var myPlaceData = RealmService.shared.realm.objects(MyPlace.self)
    var shouldCheckFaveButton = false
    
    //MARK: - Modal View 화면 관련
    // 현재 위치에서 멀리 떨어져있는 annotation을 선택하면 경로를 계산하는데 시간이 살짝 소요됨
    // -> 경로 계산 결과가 나오기 전까지 기본값을 먼저 label에 표출
    // -> 계산이 끝나면 didSet을 통해 새로운 label 업데이트
    var estimatedDistance = BehaviorRelay<String>(value: "거리: 계산중...")
    var estimatedTime = BehaviorRelay<String>(value: "소요시간: 계산중...")
    
    // 장소 이름 얻기
    var placeName: Observable<String> {
        return Observable<String>.just(self.itemViewModel.name)
    }
    
    // 거리
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
    
    // 소요시간
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
    
    //MARK: - Custom Modal View를 확장했을 때의 TableView Cell 정보 관련
    
    // 개수 정보
    let numberOfSections: Int = 1
    var numberOfRows: Int {
        return self.infoArray.count
    }
    
    // 항목 이름 정보
    var titleInfo: Observable<[String]> {
        return Observable<[String]>.just(self.titleArray)
    }
    
    // 항목 내용 정보
    var subtitleInfo: Observable<[String]> {
        return Observable<[String]>.just(self.infoArray)
    }
    
    //MARK: - Realm DB 관련
    
    // Realm DB에 즐겨찾기 데이터 저장하기
    func addMyPlaceData() {
        let dataToAppend = MyPlace(
            pinNumber: self.pinNumber,
            saveDate: "\(Date())"
        )
        RealmService.shared.create(dataToAppend)
        
        SPIndicatorService.shared.showIndicator(title: "등록 완료")
    }
    
    // Realm DB에서 즐겨찾기 데이터 삭제하기
    func removeMyPlaceData() {
        // myPlaceData가 비어있지 않은 경우,
        // pinData의 name과 같은 name을 가지고 있는 myPlaceData 삭제
        guard self.myPlaceData.count != 0 else { return }
        
        // 뒤에서부터 삭제
        for index in stride(from: self.myPlaceData.count-1, to: -1, by: -1) {
            if self.pinNumber == self.myPlaceData[index].pinNumber {
                RealmService.shared.delete(self.myPlaceData[index])
            }
        }
  
        // 즐겨찾기 장소가 제거되었으므로 MapView에서 핀을 제거하도록 알리기
        NotificationCenter.default.post(name: Notification.Name("removeMarkedPin"), object: nil)
        
        SPIndicatorService.shared.showIndicator(title: "삭제 완료")
    }
    
    // Realm DB의 MyPlace에 저장된 모든 데이터의 pinNumber와
    // 사용자가 현재 선택한 pinNumber의 일치 여부 확인
    func checkPinNumber() -> Bool {
        for index in 0..<self.myPlaceData.count {
            if self.myPlaceData[index].pinNumber == self.pinNumber {
                return true
            }
        }
        return false
    }
        
}


//MARK: - Place Info Item View Model

// 뉴스 아이템(셀) 하나하나에 대한 뷰모델
final class PlaceInfoItemViewModel {
    
    let publicData: PublicData
    
    init(_ publicData: PublicData) {
        self.publicData = publicData
    }
    
}
