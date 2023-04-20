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
    let shouldReloadTableView = BehaviorSubject<Bool>(value: false)
    
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
            UIAction(title: "날짜 느린 순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .ascendingByDate)
                self.shouldReloadTableView.onNext(true)
            }),
            UIAction(title: "날짜 빠른 순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .descendingByDate)
                self.shouldReloadTableView.onNext(true)
            }),
            UIAction(title: "소요시간 적은 순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .ascendingByTime)
                self.shouldReloadTableView.onNext(true)
            }),
            UIAction(title: "소요시간 많은 순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .descendingByTime)
                self.shouldReloadTableView.onNext(true)
            }),
            UIAction(title: "이동거리 적은 순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .ascendingByDistance)
                self.shouldReloadTableView.onNext(true)
            }),
            UIAction(title: "이동거리 많은 순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .descendingByDistance)
                self.shouldReloadTableView.onNext(true)
            }),
        ]
    }
    
    // context menu 설정하기
    func getContextMenu() -> UIMenu {
        return UIMenu(title: "목록 정렬 기준",
                      options: [.displayInline],
                      children: self.menuItems)
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
        RealmService.shared.delete(self.itemViewModel.trackData[row])
    }
    
}

// TableView Cell에 대한 ViewModel
final class MyPlaceItemViewModel {
    
    var trackData: Results<TrackData>
    var sortedTrackData: Results<TrackData>!
    
    init(realmDB: Results<TrackData>) {
        self.trackData = realmDB
    }
    
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
