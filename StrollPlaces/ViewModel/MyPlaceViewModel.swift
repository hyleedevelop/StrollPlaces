//
//  MyPlaceViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/02.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

final class MyPlaceViewModel {
    
    //MARK: - property
    
    var mainImageRelay = BehaviorRelay<UIImage>(value: UIImage())
    var nameRelay = BehaviorRelay<String>(value: "데이터를 불러오는중...")
    var timeRelay = BehaviorRelay<String>(value: "데이터를 불러오는중...")
    var distanceRelay = BehaviorRelay<String>(value: "데이터를 불러오는중...")
    var dateRelay = BehaviorRelay<String>(value: "데이터를 불러오는중...")
    
    //MARK: - initializer
    
    
    
    //MARK: - directly called method
    
    // 나만의 산책길 데이터 개수 가져오기
    func getNumberOfMyPlaces() -> Int {
        return RealmService.shared.realm.objects(TrackData.self).count
    }
    
    func loadTableViewCell(at row: Int) {
        let realmDB = RealmService.shared.realm.objects(TrackData.self)
        
        self.nameRelay.accept(realmDB[row].name ?? "이름없음")
        self.timeRelay.accept("⏱️ \(realmDB[row].time)")
        self.distanceRelay.accept("📍 \(realmDB[row].distance) km")
        self.dateRelay.accept("📆 \(realmDB[row].date)")
    }
    
    //MARK: - indirectly called method
    
    
    
}
