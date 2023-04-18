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

// 나만의 산책길 화면에 대한 ViewModel
final class MyPlaceViewModel {
    
    //MARK: - property
    
    var itemViewModel: MyPlaceItemViewModel!
    
    //MARK: - initializer
    
    init() {
        let db = RealmService.shared.realm.objects(TrackData.self)
        self.itemViewModel = MyPlaceItemViewModel(realmDB: db)
    }
    
    //MARK: - directly called method
    
    // 나만의 산책길 데이터 개수 가져오기
    func getNumberOfMyPlaces() -> Int {
        return self.itemViewModel.trackData.count
    }
    
}

// TableView Cell에 대한 ViewModel
final class MyPlaceItemViewModel {
    
    var trackData: Results<TrackData>
    
    init(realmDB: Results<TrackData>) {
        self.trackData = realmDB
    }
    
}
