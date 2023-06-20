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

//MARK: - 나만의 산책길 화면에 대한 ViewModel

final class MyPlaceViewModel: CommonViewModel {
    
    //MARK: - property
    
    var itemViewModel: MyPlaceItemViewModel!
    private var sortMenuItems = [UIAction]()
    private var moreMenuItems = [UIAction]()
    private let userDefaults = UserDefaults.standard
    
    //MARK: - 생성자 관련
    
    override init() {
        super.init()
        
        // TrackData와 TrackPoint의 인스턴스 생성
        let tracks = RealmService.shared.realm.objects(TrackData.self)
        let points = RealmService.shared.realm.objects(TrackPoint.self)
        let index = UserDefaults.standard.integer(forKey: K.UserDefaults.selectedContextMenu)
        
        // MyPlaceItemViewModel 초기화
        self.itemViewModel = MyPlaceItemViewModel(track: tracks, point: points)
        
        // context menu item 설정
        self.initializeContextMenuItems(stateOn: index)
        
        // 나만의 산책길 목록 정렬 기준 기본값 (등록 날짜 오래된 것부터 나열)
        self.itemViewModel.getSortedTrackData(
            mode: MyPlaceSorting(rawValue: index) ?? .ascendingByDate
        )
    }
    
    //MARK: - Action 관련
    
    // context menu item 초기화
    private func initializeContextMenuItems(stateOn: Int) {
        self.sortMenuItems = [
            UIAction(title: "이전 등록순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .ascendingByDate)
                self.userDefaults.set(0, forKey: "selectedContextMenu")
            }),
            UIAction(title: "최근 등록순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .descendingByDate)
                self.userDefaults.set(1, forKey: "selectedContextMenu")
            }),
            UIAction(title: "소요시간 적은순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .ascendingByTime)
                self.userDefaults.set(2, forKey: "selectedContextMenu")
            }),
            UIAction(title: "소요시간 많은순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .descendingByTime)
                self.userDefaults.set(3, forKey: "selectedContextMenu")
            }),
            UIAction(title: "이동거리 적은순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .ascendingByDistance)
                self.userDefaults.set(4, forKey: "selectedContextMenu")
            }),
            UIAction(title: "이동거리 많은순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .descendingByDistance)
                self.userDefaults.set(5, forKey: "selectedContextMenu")
            }),
            UIAction(title: "별점 낮은순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .ascendingByRating)
                self.userDefaults.set(6, forKey: "selectedContextMenu")
            }),
            UIAction(title: "별점 높은순", handler: { [weak self] _ in
                guard let self = self else { return }
                self.itemViewModel.getSortedTrackData(mode: .descendingByRating)
                self.userDefaults.set(7, forKey: "selectedContextMenu")
            }),
        ]
        
        self.sortMenuItems[stateOn].state = .on
    }
    
    // 나만의 산책길 목록 정렬을 위한 context menu 설정
    var sortContextMenu: UIMenu {
        return UIMenu(title: "정렬 방법", options: [.singleSelection], children: self.sortMenuItems)
    }
    
    // 나만의 산책길 목록 정렬을 위한 context menu 아이템 가져오기
    func getSortContextMenuItems() -> [UIAction] {
        return self.sortMenuItems
    }
    
    //MARK: - Collection View 관련
    
    // section의 개수
    var numberOfSections: Int {
        return 1
    }
    
    // section 내 아이템의 개수
    var numberOfItemsInSection: Int {
        return self.itemViewModel.trackData.count
    }
    
    // 특정 기준에 따라 정렬시킨 나만의 산책길 데이터
    private func sortedTrackList(index: Int) -> TrackData {
        return self.itemViewModel.sortedTrackData[index]
    }
    
    // 정렬된 산책길 데이터의 별점 값
    func rating(index: Int) -> Double {
        return self.itemViewModel.sortedTrackData[index].rating
    }
    
    // 정렬된 산책길 데이터의 대표 이미지 소스
    func mainImage(index: Int) -> UIImage? {
        let imageName = self.itemViewModel.sortedTrackData[index]._id.stringValue
        return self.loadImageFromDocumentDirectory(imageName: imageName)
    }
    
    // 정렬된 산책길 데이터의 제목
    func name(index: Int) -> String {
        if self.itemViewModel.sortedTrackData[index].name.isEmpty {
            return "제목없음"
        } else {
            return self.itemViewModel.sortedTrackData[index].name
        }
    }
    
    // 정렬된 산책길 데이터의 소요시간
    func time(index: Int) -> String {
        return self.itemViewModel.sortedTrackData[index].time
    }
    
    // 정렬된 산책길 데이터의 거리
    func distance(index: Int) -> String {
        let distance = self.itemViewModel.sortedTrackData[index].distance
        if distance < 1000.0 {
            return String(format: "%.1f", distance) + "m"
        } else {
            return String(format: "%.2f", distance/1000.0) + "km"
        }
    }
    
    // 정렬된 산책길 데이터의 등록 날짜
    func date(index: Int) -> String {
        guard let date = self.itemViewModel.sortedTrackData[index].date.toDate(mode: .myPlace) else {
            return "알수없음"
        }
        
        return Date().getTimeIntervalString(since: date)
    }
    
    // 정렬된 산책길 데이터의 ID
    func sortedID(index: Int) -> ObjectId {
        return self.itemViewModel.sortedTrackData[index]._id
    }
    
    func indexOfRealm(id: ObjectId) -> Int? {
        return self.itemViewModel.trackData.firstIndex(where: { $0._id == id })
    }
    
    //MARK: - Realm DB 관련
    
    // 특정 row의 TrackData 삭제하기
    func removeTrackData(at row: Int) {
        let trackDataId = self.itemViewModel.trackData[row]._id.stringValue
  
        // trackData의 id와 같은 id를 가지고 있는 trackPoint 삭제 (뒤에서부터)
        for index in stride(from: self.itemViewModel.trackpoint.count-1, to: -1, by: -1) {
            if trackDataId == self.itemViewModel.trackpoint[index].id {
                RealmService.shared.delete(self.itemViewModel.trackpoint[index])
            }
        }
        
        // trackData 삭제
        RealmService.shared.delete(self.itemViewModel.trackData[row])
        
        // 지도 이미지 삭제
        self.deleteImageFromDocumentDirectory(imageName: trackDataId)
        
        // Tab Bar 뱃지의 숫자 업데이트 알리기
        NotificationCenter.default.post(name: Notification.Name("updateBadge"), object: nil)
        
        // 삭제 후 나만의 산책길 목록이 비어있다면 Lottie Animation 표출하기
        if self.itemViewModel.trackData.count == 0 {
            // userdefaults 값 false로 초기화 -> Lottie Animation 표출
            self.userDefaults.set(false, forKey: "myPlaceExist")
            NotificationCenter.default.post(name: Notification.Name("showLottieAnimation"), object: nil)
        }
    }
    
    //MARK: - 스크린샷 이미지 관련
    
    // 지도 스크린샷 이미지 불러오기
    func loadImageFromDocumentDirectory(imageName: String) -> UIImage? {
        // 1. 폴더 경로 가져오기
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let directoryPath = path.first {
            // 2. 이미지 URL 만들기
            let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(imageName)
            // 3. UIImage로 불러오기
            return UIImage(contentsOfFile: imageURL.path)
        }
        
        return nil
    }
    
    private func deleteImageFromDocumentDirectory(imageName: String) {
        // 1. 폴더 경로 가져오기
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        // 2. 이미지 URL 만들기
        let imageURL = documentDirectory.appendingPathComponent(imageName + ".png")
        
        // 3. 파일이 존재하면 삭제하기
        if FileManager.default.fileExists(atPath: imageURL.path) {
            do {
                try FileManager.default.removeItem(at: imageURL)
            } catch {
                print("이미지를 삭제하지 못했습니다.")
            }
        }
    }
    
}

//MARK: - CollectionView Cell에 대한 ViewModel

final class MyPlaceItemViewModel {
    
    //MARK: - property
    
    private let userDefaults = UserDefaults.standard
    lazy var shouldShowAnimationView = BehaviorSubject<Bool>(
        value: !self.userDefaults.bool(forKey: "myPlaceExist")
    )
    let collectionViewShouldBeReloaded = BehaviorSubject<Bool>(value: false)
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
            self.collectionViewShouldBeReloaded.onNext(true)
        }
    }
    var sortedTrackData: Results<TrackData>! {
        didSet {
            self.collectionViewShouldBeReloaded.onNext(true)
        }
    }
    var trackpoint: Results<TrackPoint>
    
    //MARK: - initializer
    
    init(track: Results<TrackData>, point: Results<TrackPoint>) {
        self.trackData = track
        self.trackpoint = point
    }
    
    //MARK: - directly called method
    
    // Realm DB의 TrackData를 정렬하여 sortedTrackData에 넣기
    func getSortedTrackData(mode: MyPlaceSorting) {
        var variableName = String()
        var isAscendingOrder = Bool()
        
        switch mode {
        case .descendingByDate: variableName = "date" ; isAscendingOrder = false
        case .ascendingByDate: variableName = "date" ; isAscendingOrder = true
        case .descendingByTime: variableName = "time" ; isAscendingOrder = false
        case .ascendingByTime: variableName = "time" ; isAscendingOrder = true
        case .descendingByDistance: variableName = "distance" ; isAscendingOrder = false
        case .ascendingByDistance: variableName = "distance" ; isAscendingOrder = true
        case .descendingByRating: variableName = "rating" ; isAscendingOrder = false
        case .ascendingByRating: variableName = "rating" ; isAscendingOrder = true
        }
        
        self.sortedTrackData = self.trackData.sorted(byKeyPath: variableName, ascending: isAscendingOrder)
    }
    
}
