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
    private var menuItems = [UIAction]()
    
    //MARK: - initializer
    
    init() {
        let db = RealmService.shared.realm.objects(TrackData.self)
        self.itemViewModel = MyPlaceItemViewModel(realmDB: db)
        
        // context menu item 설정
        self.initializeContextMenuItems()
        
        // 나만의 산책길 목록 정렬 기준 기본값 (등록 날짜 오래된 것부터 나열)
        self.itemViewModel.getSortedTrackData(mode: .ascendingByDate)
    }
    
    //MARK: - directly called method
    
    // context menu item 초기화
    private func initializeContextMenuItems() {
        self.menuItems = [
            UIAction(title: "등록날짜 느린 순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .descendingByDate)
            }),
            UIAction(title: "등록날짜 빠른 순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .ascendingByDate)
            }),
            UIAction(title: "소요시간 적은 순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .ascendingByTime)
            }),
            UIAction(title: "소요시간 많은 순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .descendingByTime)
            }),
            UIAction(title: "이동거리 적은 순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .ascendingByDistance)
            }),
            UIAction(title: "이동거리 많은 순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .descendingByDistance)
            }),
        ]
    }
    
    // context menu 설정하기
    func getContextMenu() -> UIMenu {
        return UIMenu(title: "목록 정렬 기준", options: [.displayInline], children: self.menuItems)
    }
    
    // context menu 아이템 가져오기
    func getContextMenuItems() -> [UIAction] {
        return self.menuItems
    }
    
    // 나만의 산책길 데이터 개수 가져오기
    func getNumberOfMyPlaces() -> Int {
        return self.itemViewModel.trackData.count
    }
    
    // 특정 row의 TrackData 삭제하기
    func removeTrackData(at row: Int) {
        // Realm DB에서 trackData 삭제
        RealmService.shared.delete(self.itemViewModel.trackData[row])
        
        
    }
    
}

// TableView Cell에 대한 ViewModel
final class MyPlaceItemViewModel {
    
    //MARK: - property
    
    private let userDefaults = UserDefaults.standard
    lazy var shouldShowAnimationView = BehaviorSubject<Bool>(
        value: !self.userDefaults.bool(forKey: "myPlaceExist")
    )
    let shouldReloadTableView = BehaviorSubject<Bool>(value: false)
    var trackData: Results<TrackData> {
        didSet {
            // 나만의 산책길 목록이 비어있는지의 여부를 UserDefaults에 저장
            if self.trackData.count > 0 {
                self.userDefaults.set(true, forKey: "myPlaceExist")
                self.shouldShowAnimationView.onNext(false)
            } else {
                self.userDefaults.set(false, forKey: "myPlaceExist")
                self.shouldShowAnimationView.onNext(true)
            }
        }
    }
    var sortedTrackData: Results<TrackData>! {
        didSet {
            self.shouldReloadTableView.onNext(true)
        }
    }
    
    //MARK: - initializer
    
    init(realmDB: Results<TrackData>) {
        self.trackData = realmDB
    }
    
    //MARK: - directly called method
    
    // Realm DB의 TrackData를 정렬하여 sortedTrackData에 넣기
    func getSortedTrackData(mode: MyPlaceSorting) {
        switch mode {
        case .descendingByDate:
            self.sortedTrackData = self.trackData.sorted(byKeyPath: "date", ascending: false)
        case .ascendingByDate:
            self.sortedTrackData = self.trackData.sorted(byKeyPath: "date", ascending: true)
        case .descendingByTime:
            self.sortedTrackData = self.trackData.sorted(byKeyPath: "time", ascending: false)
        case .ascendingByTime:
            self.sortedTrackData = self.trackData.sorted(byKeyPath: "time", ascending: true)
        case .descendingByDistance:
            self.sortedTrackData = self.trackData.sorted(byKeyPath: "distance", ascending: false)
        case .ascendingByDistance:
            self.sortedTrackData = self.trackData.sorted(byKeyPath: "distance", ascending: true)
        }
    }
    
}
