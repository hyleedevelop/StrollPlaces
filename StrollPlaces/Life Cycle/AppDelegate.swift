//
//  AppDelegate.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseAuth
import AppTrackingTransparency
import AuthenticationServices

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
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
//
//        }
        //Thread.sleep(forTimeInterval: 2)
        
        // 앱 추적 권한 허용 요청
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("Privacy - Tracking usage: authorized")
                case .denied:
                    print("Privacy - Tracking usage: denied")
                case .notDetermined:
                    print("Privacy - Tracking usage: notDetermined")
                case .restricted:
                    print("Privacy - Tracking usage: restricted")
                @unknown default:
                    print("Privacy - Tracking usage: default")
                }
            }
        }
        
        // Firebase 초기화
        FirebaseApp.configure()
        
        // Firebase에서 사용자가 이미 회원가입 되어있는지 확인
//        //let userEmail = UserDefaults.standard.string(forKey: K.UserDefaults.userEmail)
//        //if userEmail != nil || userEmail != "no email" {
//        if let user = FirebaseAuth.Auth.auth().currentUser {
//            UserDefaults.standard.setValue(true, forKey: K.UserDefaults.signupStatus)
//            UserDefaults.standard.setValue(true, forKey: K.UserDefaults.loginStatus)
//            print("사용자 등록 되어있음")
//            //print("사용자 로그인 되어 있음", user.uid, user.email ?? "-")
//        } else {
//            UserDefaults.standard.setValue(false, forKey: K.UserDefaults.signupStatus)
//            UserDefaults.standard.setValue(false, forKey: K.UserDefaults.loginStatus)
//            print("사용자 등록 되어있지 않음")
//        }
        
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
    
    // 앱 종료 직전에 호출되는 메서드로,
    // MY산책길을 생성하는 도중 Realm DB에 데이터 생성을 완전히 마치지 않은 상태에서
    // 앱이 강제로(비정상적으로) 종료되었을 때, 미완성된 산책길 데이터 지우기
    func applicationWillTerminate(_ application: UIApplication) {
        // 오브젝트 접근을 위한 변수
        let track = RealmService.shared.trackDataObject
        let point = RealmService.shared.trackPointObject
        
        // 가장 마지막에 저장된 TrackData 오브젝트 데이터에 접근 시도
        guard let latestTrackData = track.last,
              latestTrackData.name.isEmpty else { return }
        
        // 1. TrackPoint 오브젝트의 경로 지점의 위치정보를 하나씩 삭제
        for _ in 0..<latestTrackData.points.count {
            guard let latestPointData = point.last else { return }
            RealmService.shared.delete(latestPointData)
        }
        
        // 2. 이미지 파일 삭제
        // 2-1. 폴더 경로 가져오기
        guard let documentDirectory = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first else { return }
        // 2-2. 이미지 URL 만들기
        let imageURL = documentDirectory.appendingPathComponent(
            latestTrackData._id.stringValue + ".png"
        )
        // 2-3. 파일이 존재하면 삭제하기
        if FileManager.default.fileExists(atPath: imageURL.path) {
            do { try FileManager.default.removeItem(at: imageURL) }
            catch { print("이미지를 삭제하지 못했습니다.") }
        }
        
        // 3. TrackData 오브젝트 내 데이터 삭제
        RealmService.shared.delete(latestTrackData)
    }

}

