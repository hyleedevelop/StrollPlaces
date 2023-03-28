//
//  RealmService.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/28.
//

import UIKit
import RealmSwift

final class RealmService {
    
    static let shared = RealmService()
    private init() {}
    
    // Realm() 으로 선언한 변수는 Document/ 밑에 있는 realm DB 에 대한 포인터이다.
    // 기존에 생성한 realm DB가 없다면 자동으로 생성한다.
    var realm = try! Realm()
    
    // T는 Generic이다.
    // T는 typename의 약어이며, 모든 Object를 받을 수 있음을 의미한다.
    func create<T: Object>(_ object: T) {
        do {
            // realm에 object를 추가.
            try realm.write {
                realm.add(object)
            }
        } catch {
            post(error)
        }
    }
    
    // CRUD의 'U'
    func update<T: Object>(_ object: T, with dictionary: [String: Any?]) {
        do {
            try realm.write {
                for (key, value) in dictionary {
                    object.setValue(value, forKey: key)
                }
            }
        } catch {
            post(error)
        }
    }
    
    // CRUD의 'D'
    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            post(error)
        }
    }
    
    func post(_ error: Error) {
        NotificationCenter.default.post(
            name: Notification.Name("RealmError"),
            object: error)
    }
    
    func observeRealmErrors(in vc: UIViewController,
                            completion: @escaping (Error?) -> Void) {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("RealmError"),
            object: nil,
            queue: nil) { (notification) in
                completion(notification.object as? Error)
            }
    }
    
    func stopObservingErrors(in vc: UIViewController) {
        NotificationCenter.default.removeObserver(vc, name: NSNotification.Name("RealmError"), object: nil)
    }
    
}
