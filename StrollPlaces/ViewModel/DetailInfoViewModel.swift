//
//  DetailInfoViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/02.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RealmSwift
import CoreLocation
import MapKit

final class DetailInfoViewModel {
    
    //MARK: - property
    
    var trackData = RealmService.shared.realm.objects(TrackData.self)
    private var pointData = RealmService.shared.realm.objects(TrackPoint.self)
    private var points = [CLLocationCoordinate2D]()
    
    let nameRelay = BehaviorRelay<String>(value: "알수없음")
    let dateRelay = BehaviorRelay<String>(value: "알수없음")
    let timeRelay = BehaviorRelay<String>(value: "알수없음")
    let distanceRelay = BehaviorRelay<String>(value: "알수없음")
    let explanationRelay = BehaviorRelay<String>(value: "알수없음")
    let featureRelay = BehaviorRelay<String>(value: "알수없음")
    let ratingRelay = BehaviorRelay<String>(value: "알수없음")
    
    //MARK: - initializer
    
    init() {
        
    }
    
    //MARK: - directly called method
    
    // Realm DB에 임시저장 해놓은 경로 데이터를 받아 relay에서 요소 방출
    func getTrackDataFromRealmDB(index: Int) {
        var nameString: String {
            return RealmService.shared.realm.objects(TrackData.self)[index].name
        }
        self.nameRelay.accept(nameString)
        
        var dateString: String {
            return RealmService.shared.realm.objects(TrackData.self)[index].date
        }
        self.dateRelay.accept(dateString)
        
        var timeString: String {
            return RealmService.shared.realm.objects(TrackData.self)[index].time
        }
        self.timeRelay.accept(timeString)
        
        var distanceString: String {
            let distance = RealmService.shared.realm.objects(TrackData.self).last?.distance ?? 0.0
            if (..<1000) ~= distance {
                return String(format: "%.1f", distance) + "m"
            } else {
                return String(format: "%.2f", distance/1000.0) + "km"
            }
        }
        self.distanceRelay.accept(distanceString)
        
        var explanationString: String {
            return RealmService.shared.realm.objects(TrackData.self)[index].explanation
        }
        self.explanationRelay.accept(explanationString)
        
        var featureString: String {
            return RealmService.shared.realm.objects(TrackData.self)[index].feature
        }
        self.featureRelay.accept(featureString)
        
        var ratingString : String {
            return "\(RealmService.shared.realm.objects(TrackData.self)[index].rating) / 5"
        }
        self.ratingRelay.accept(ratingString)
    }
    
    // MapView에 이동경로를 표시하기 위해 track point 데이터를 좌표로 변환 후 가져오기
    func getTrackPointForPolyline(index: Int) -> [CLLocationCoordinate2D] {
        // Realm DB에서 자료 읽기 및 빈 배열 생성
        let trackPoint = RealmService.shared.realm.objects(TrackData.self)[index].points
        
        // List<TrackPoint> (위도+경도) -> CLLocationCoordinate2D (좌표)
        for index in 0..<trackPoint.count {
            let coordinate = CLLocationCoordinate2DMake(trackPoint[index].latitude,
                                                        trackPoint[index].longitude)
            self.points.append(coordinate)
        }
        
        return self.points
    }
    
    // 경로를 보여줄 영역 정보 가져오기
    func getDeltaCoordinate() -> (Double, Double)? {
        var latitudeArray = [Double]()
        var longitudeArray = [Double]()
        
        for index in 0..<self.points.count {
            latitudeArray.append(self.points[index].latitude)
            longitudeArray.append(self.points[index].longitude)
        }
        
        if latitudeArray.max() != nil, latitudeArray.min() != nil,
           longitudeArray.max() != nil, longitudeArray.min() != nil {
            let latitudeDelta = abs(latitudeArray.max()! - latitudeArray.min()!) * 2.0
            let longitudeDelta = abs(longitudeArray.max()! - longitudeArray.min()!) * 2.0
            return (latitudeDelta, longitudeDelta)
        } else {
            return nil
        }
    }
    
    // 상세정보 화면에서 편집 버튼을 통해 Realm DB 업데이트 하기
    func updateDB(index: Int, newValue: String, item: EditableItems) {
        let realm = try! Realm()
        let primaryKey = RealmService.shared.realm.objects(TrackData.self)[index]._id
        var dictionary = [String: Any]()
        
        switch item {
        case .name: dictionary = ["_id": primaryKey, "name": newValue]
        case .explanation: dictionary = ["_id": primaryKey, "explanation": newValue]
        case .feature: dictionary = ["_id": primaryKey, "feature": newValue]
        }
        
        try! realm.write {
            realm.create(TrackData.self, value: dictionary as [String: Any], update: .modified)
        }
        
        switch item {
        case .name: self.nameRelay.accept(newValue)
        case .explanation: self.explanationRelay.accept(newValue)
        case .feature: self.featureRelay.accept(newValue)
        }
    }
    
}
