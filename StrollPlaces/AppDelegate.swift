//
//  AppDelegate.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // IQKeyboard 사용 가능 여부
        IQKeyboardManager.shared.enable = true
        // 자동 ToolBar 설정 여부
        IQKeyboardManager.shared.enableAutoToolbar = true
        // 키보드 바깥을 터치했을 때 Resign 여부
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        // Toolbar 버튼 설정
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Close"
        // IQKeyboard의 이전/이후 버튼 조절이 허용된 View
        // (해당 View 내의 TextField끼리는 이전/이후 버튼을 통해 상호 간편이동이 가능해짐)
        //IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses = [SomeView.self]
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // 앱 종료 직전에 호출
    func applicationWillTerminate(_ application: UIApplication) {
        // 나만의 산책길을 만들던 도중 앱이 강제로 종료되는 등
        // 산책길 정보 입력이 완료되지 않은 경우 임시 저장했던 경로 데이터 지우기
        let track = RealmService.shared.realm.objects(TrackData.self)
        let point = RealmService.shared.realm.objects(TrackPoint.self)
        
        // 가장 마지막에 저장된 TrackData에 접근
        guard let latestTrackData = track.last else { return }
        
        if latestTrackData.name.isEmpty {
            for _ in 0..<latestTrackData.points.count {
                guard let latestPointData = point.last else { return }
                // TrackPoint에서 points의 갯수 만큼 삭제
                RealmService.shared.delete(latestPointData)
            }
            
            // TrackData 삭제
            RealmService.shared.delete(latestTrackData)
            
            // 이미지 파일 삭제
            guard let documentDirectory = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let imageName = track.last?._id.stringValue ?? "noname"
            let imageURL = documentDirectory.appendingPathComponent(imageName + ".png")
            if FileManager.default.fileExists(atPath: imageURL.path) {
                do {
                    try FileManager.default.removeItem(at: imageURL)
                } catch {
                    print("이미지를 삭제하지 못했습니다.")
                }
            }
        }
        
    }

}

