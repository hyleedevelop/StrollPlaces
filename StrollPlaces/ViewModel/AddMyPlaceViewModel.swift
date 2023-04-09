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
    
    var dateRelay = BehaviorRelay<String>(value: "N/A")
    var timeRelay = BehaviorRelay<String>(value: "N/A")
    var distanceRelay = BehaviorRelay<String>(value: "N/A")
    var firstLocationRelay = BehaviorRelay<String>(value: "N/A")
    var lastLocationRelay = BehaviorRelay<String>(value: "N/A")
    
    var primaryKey: ObjectId?
    
    //MARK: - initializer
    
    init() {
        
    }
    
    //MARK: - directly called method
    
    // Realm DB에 임시저장 해놓은 경로 데이터를 받아 relay에서 요소 방출
    func getTrackDataFromRealmDB() {
        self.primaryKey = RealmService.shared.realm.objects(TrackData.self).last?._id
        
        let date = RealmService.shared.realm.objects(TrackData.self).last?.date ?? Date()
        self.dateRelay.accept("\(date)")
        
        let time = RealmService.shared.realm.objects(TrackData.self).last?.time ?? "알수없음"
        self.timeRelay.accept(time)
        
        let distance = RealmService.shared.realm.objects(TrackData.self).last?.distance ?? 0.0
        self.distanceRelay.accept("\(distance) km")
        
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
        //guard let latestPointData = self.point else { return }
        RealmService.shared.delete(latestTrackData)
    }
    
    //MARK: - indirectly called method
    
    
}
