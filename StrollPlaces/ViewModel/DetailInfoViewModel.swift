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
    private var primaryKey = RealmService.shared.realm.objects(TrackData.self).last?._id
    private var points = [CLLocationCoordinate2D]()
    
    var dateRelay = BehaviorRelay<String>(value: "알수없음")
    var timeRelay = BehaviorRelay<String>(value: "알수없음")
    var distanceRelay = BehaviorRelay<String>(value: "알수없음")
    
    //MARK: - initializer
    
    init() {
        
    }
    
    //MARK: - directly called method
    
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
    
    
}
