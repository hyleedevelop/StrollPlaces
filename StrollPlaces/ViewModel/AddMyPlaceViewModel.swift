//
//  AddMyPlaceViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/02.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RealmSwift
import CoreLocation

final class AddMyPlaceViewModel {
    
    //MARK: - property
    
    private var trackData = RealmService.shared.realm.objects(TrackData.self)
    private var pointData = RealmService.shared.realm.objects(TrackPoint.self)
    private var primaryKey = RealmService.shared.realm.objects(TrackData.self).last?._id
    private var points = [CLLocationCoordinate2D]()
    
    var dateRelay = BehaviorRelay<String>(value: "알수없음")
    var timeRelay = BehaviorRelay<String>(value: "알수없음")
    var distanceRelay = BehaviorRelay<String>(value: "알수없음")
    var firstLocationRelay = BehaviorRelay<String>(value: "알수없음")
    var lastLocationRelay = BehaviorRelay<String>(value: "알수없음")
    
    //MARK: - initializer
    
    init() {
        
    }
    
    //MARK: - directly called method
    
    // Realm DB에 임시저장 해놓은 경로 데이터를 받아 relay에서 요소 방출
    func getTrackDataFromRealmDB() {
        //self.primaryKey = RealmService.shared.realm.objects(TrackData.self).last?._id
        
        var dateString: String {
            //let date = RealmService.shared.realm.objects(TrackData.self).last?.date ?? Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
            return dateFormatter.string(from: Date())
        }
        self.dateRelay.accept(dateString)
        
        var timeString: String {
            let time = RealmService.shared.realm.objects(TrackData.self).last?.time ?? "알수없음"
            return "\(time)"
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
        
        let startPoint = RealmService.shared.realm.objects(TrackData.self).last?.firstLocation ?? "알수없음"
        self.firstLocationRelay.accept(startPoint)
        
        let endPoint = RealmService.shared.realm.objects(TrackData.self).last?.lastLocation ?? "알수없음"
        self.lastLocationRelay.accept(endPoint)
    }
    
    // MapView에 이동경로를 표시하기 위해 track point 데이터를 좌표로 변환 후 가져오기
    func getTrackPointForPolyline() -> [CLLocationCoordinate2D] {
        // Realm DB에서 자료 읽기 및 빈 배열 생성
        let trackPoint = RealmService.shared.realm.objects(TrackData.self).last?.points
        
        // List<TrackPoint> (위도+경도) -> CLLocationCoordinate2D (좌표)
        guard let tp = trackPoint else { fatalError("could not find track points...") }
        for index in 0..<tp.count {
            let coordinate = CLLocationCoordinate2DMake(tp[index].latitude,
                                                        tp[index].longitude)
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
            let latitudeDelta = abs(latitudeArray.max()! - latitudeArray.min()!) * 1.5
            let longitudeDelta = abs(longitudeArray.max()! - longitudeArray.min()!) * 1.5
            return (latitudeDelta, longitudeDelta)
        } else {
            return nil
        }
    }
    
    // Realm DB에 데이터 추가하기
    func updateTrackData(name: String, explanation: String, feature: String) {
        // TrackData의 id, name, explanation, feature 업데이트
        let realm = try! Realm()
        try! realm.write {
            realm.create(TrackData.self,
                         value: ["_id": self.primaryKey!,
                                 "name": name,
                                 "explanation": explanation,
                                 "feature": feature]
                         as [String: Any],
                         update: .modified)
        }
        
        // TrackPoint의 id 업데이트
        let rangeEnd = self.pointData.count
        let rangeStart = rangeEnd - (self.trackData.last?.points.count)!
        for index in rangeStart..<rangeEnd {
            let pointDB = realm.objects(TrackPoint.self)
            try! realm.write {
                pointDB[index].id = self.primaryKey!.stringValue
            }
        }
    }
    
    // 임시로 저장했던 경로 데이터 지우기
    func clearTemporaryTrackData() {
        //self.trackData = RealmService.shared.realm.objects(TrackData.self)
        //self.pointData = RealmService.shared.realm.objects(TrackPoint.self)
        
        // 가장 마지막에 저장된 TrackData에 접근
        guard let latestTrackData = self.trackData.last else { return }
        for _ in 0..<latestTrackData.points.count {
            guard let latestPointData = self.pointData.last else { return }
            // TrackPoint에서 points의 갯수 만큼 삭제
            RealmService.shared.delete(latestPointData)
        }
        
        // TrackData 삭제
        RealmService.shared.delete(latestTrackData)
    }
    
    func checkIfThereIsTheSameName(name: String) -> Bool {
        // 입력한 산책길 이름이 Realm DB에 저장된 산책길 이름과 중복되는지 체크
        self.trackData = RealmService.shared.realm.objects(TrackData.self)
        return self.trackData.firstIndex(where: { $0.name == name } ) == nil ? true : false
    }
    
}
