//
//  RealmService.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/28.
//

import UIKit
//import Realm
import RxSwift
import RealmSwift

final class RealmService {
    
    static let shared = RealmService()
    private init() {}
    
    // Realm() 으로 선언한 변수는 Document/ 밑에 있는 realm DB 에 대한 포인터이다.
    // 기존에 생성한 realm DB가 없다면 자동으로 생성한다.
    private var realm = try! Realm()
    let isTrackDataUpdated = PublishSubject<Bool>()
    
    //MARK: - Create
    
    // 오브젝트 생성
    func create<T: Object>(_ object: T) {
        do {
            try self.realm.write {
                self.realm.add(object)
            }
        } catch {
            self.post(error)
        }
    }
    
    // TrackData 요소 추가
    func addTrackData(name: String, explanation: String, feature: String, rating: Double) {
        let primaryKey = self.trackDataObject.last?._id
        
        try! self.realm.write {
            self.realm.create(
                TrackData.self,
                value: ["_id": primaryKey ?? "",
                        "name": name,
                        "explanation": explanation,
                        "feature": feature,
                        "rating": rating]
                as [String: Any],
                update: .modified
            )
        }
        
        // TrackPoint의 id 업데이트
        let rangeEnd = self.trackPointObject.count
        let rangeStart = rangeEnd - (self.readLastTrackData?.points.count)!
        for index in rangeStart..<rangeEnd {
            let pointDB = self.trackPointObject
            try! realm.write {
                pointDB[index].id = primaryKey!.stringValue
            }
        }
        
        self.isTrackDataUpdated.onNext(true)
    }
    
    //MARK: - Read
    
    // realm은 읽어낸 data 컬렉션을 memory에 올리지 않고 정보를 얻기 때문에
    // 다른 DB 라이브러리보다 훨씬 효율적이다.
    
    // MyPlace 오브젝트에 접근
    var myPlaceObject: Results<MyPlace> {
        return self.realm.objects(MyPlace.self)
    }
    
    // TrackData 오브젝트에 접근
    var trackDataObject: Results<TrackData> {
        return self.realm.objects(TrackData.self)
    }
    
    // TrackPoint 오브젝트에 접근
    var trackPointObject: Results<TrackPoint> {
        return self.realm.objects(TrackPoint.self)
    }
    
    // TrackData 오브젝트의 index번째 요소에 접근
    func readTrackData(at index: Int) -> TrackData {
        return self.trackDataObject[index]
    }
    
    // TrackData 오브젝트의 마지막 요소에 접근
    var readLastTrackData: TrackData? {
        return self.trackDataObject.last
    }
    
    // TrackPoint 오브젝트의 index번째 요소에 접근
    func readTrackPoints(at index: Int) -> List<TrackPoint> {
        return self.trackDataObject[index].points
    }
    
    //MARK: - Update
    
    // TrackData 오브젝트의 index번째 요소 업데이트
    func updateTrackData(at index: Int, item: EditableItems, newValue: String) {
        let primaryKey = self.realm.objects(TrackData.self)[index]._id
        var keyValue = [String: Any]()
        
        switch item {
        case .name: keyValue = ["_id": primaryKey, "name": newValue]
        case .explanation: keyValue = ["_id": primaryKey, "explanation": newValue]
        case .feature: keyValue = ["_id": primaryKey, "feature": newValue]
        }
        
        try! self.realm.write {
            self.realm.create(
                TrackData.self,
                value: keyValue as [String: Any],
                update: .modified
            )
        }
    }
    
    //MARK: - Delete
    
    func deleteMyPlace(at index: Int) {
        do {
            try realm.write {
                realm.delete(self.myPlaceObject[index])
            }
        } catch {
            post(error)
        }
    }
    
    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            post(error)
        }
    }
    
    // MyPlace 오브젝트 요소 전체 삭제
    func deleteMyPlaceAll() {
        do {
            try self.realm.write {
                self.realm.delete(self.myPlaceObject)
            }
        } catch {
            post(error)
        }
    }
    
    // TrackData 및 TrackPoint 오브젝트 요소 삭제
    func deleteTrackAll() {
        do {
            try realm.write {
                realm.delete(self.trackDataObject)
                realm.delete(self.trackPointObject)
            }
        } catch {
            post(error)
        }
        
    }
    
    // Realm DB 내 모든 요소 삭제
    func deleteAll<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            post(error)
        }
    }
    
    //MARK: - Others
    
    func post(_ error: Error) {
        NotificationCenter.default.post(
            name: Notification.Name("RealmError"),
            object: error)
    }
    
}
