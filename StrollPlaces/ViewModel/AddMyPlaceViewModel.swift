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

final class AddMyPlaceViewModel {
    
    //MARK: - property
    
    var track: Results<TrackData>!
    var point: Results<TrackPoint>!
    
    var dateRelay = BehaviorRelay<String>(value: "알수없음")
    var timeRelay = BehaviorRelay<String>(value: "알수없음")
    var distanceRelay = BehaviorRelay<String>(value: "알수없음")
    var firstLocationRelay = BehaviorRelay<String>(value: "알수없음")
    var lastLocationRelay = BehaviorRelay<String>(value: "알수없음")
    
    var primaryKey: ObjectId?
    
    //MARK: - initializer
    
    init() {
        
    }
    
    //MARK: - directly called method
    
    // Realm DB에 임시저장 해놓은 경로 데이터를 받아 relay에서 요소 방출
    func getTrackDataFromRealmDB() {
        self.primaryKey = RealmService.shared.realm.objects(TrackData.self).last?._id
        
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
    
    // Realm DB에 데이터 추가하기
    func updateTrackData(name: String, explanation: String?, feature: String?) {
        let realm = try! Realm()
        try! realm.write {
            realm.create(TrackData.self,
                         value: ["_id": self.primaryKey!,
                                 "name": name,
                                 "explanation": explanation ?? "",
                                 "feature": feature ?? ""]
                         as [String: Any],
                         update: .modified)
        }
    }
    
    // 임시로 저장했던 경로 데이터 지우기
    func clearTemporaryTrackData() {
        self.track = RealmService.shared.realm.objects(TrackData.self)
        self.point = RealmService.shared.realm.objects(TrackPoint.self)
        
        guard let latestTrackData = self.track?.last else { return }
        RealmService.shared.delete(latestTrackData)
        
        for _ in 0..<self.point.count {
            guard let latestPointData = self.point.last else { return }
            RealmService.shared.delete(latestPointData)
        }
    }
    
    //MARK: - indirectly called method
    
    
}
