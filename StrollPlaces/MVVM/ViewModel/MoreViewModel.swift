//
//  SettingViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/14.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import MapKit
import SPIndicator

final class MoreViewModel {
    
    //MARK: - normal property
    
    private let userDefaults = UserDefaults.standard
    private let appSettings: [MoreCellData]!
    private let feedback: [MoreCellData]!
    private let aboutTheApp: [MoreCellData]!
    let moreCellData: [[MoreCellData]]!
    let shouldReloadTableView = BehaviorSubject<Bool>(value: false)
    
    //MARK: - initializer
    
    init() {
        appSettings = [
            MoreCellData(title: "지도 종류", value: nil),
            MoreCellData(title: "지도 표시 범위", value: nil),
            MoreCellData(title: "MY산책길 데이터 초기화", value: nil),
        ]

        feedback = [
            MoreCellData(title: "앱 리뷰", value: nil),
            MoreCellData(title: "문의사항", value: nil),
        ]
        
        aboutTheApp = [
            MoreCellData(title: "도움말", value: nil),
            MoreCellData(title: "라이브러리", value: nil),
            MoreCellData(title: "개인정보 정책", value: nil),
            MoreCellData(title: "이용약관", value: nil),
            MoreCellData(title: "버전", value: nil),
        ]
        
        moreCellData = [appSettings, feedback, aboutTheApp]
    }
    
    //MARK: - directly called method

//    func moreCellData(at index: Int) -> ThemeCellViewModel {
//        return self.themeCellViewModel[index]
//    }
    
    func getNumberOfSections() -> Int {
        return MoreCellSection.allCases.count
    }
    
    func getNumberOfRowsInSection(at section: Int) -> Int {
        return moreCellData[section].count
    }
    
    func getTitleForHeaderInSection(at section: Int) -> String? {
        switch MoreCellSection(rawValue: section) {
        case .appSettings:
            return K.More.appSettingsTitle
        case .feedback:
            return K.More.feedbackTitle
        case .aboutTheApp:
            return K.More.aboutTheAppTitle
        case .none:
            return nil
        }
    }
    
    // 이 앱의 버전을 문자열로 가져오기
    func getCurrentAppVersion() -> String {
        if let info: [String: Any] = Bundle.main.infoDictionary,
           let currentVersion: String = info["CFBundleShortVersionString"] as? String {
            return currentVersion
        }
        return "nil"
    }
    
    // 이 앱의 빌드 넘버를 문자열로 가져오기
    func getCurrentBuildNumber() -> String {
        if let info: [String: Any] = Bundle.main.infoDictionary,
           let buildNumber: String = info["CFBundleVersion"] as? String {
            return buildNumber
        }
        return "nil"
    }
    
    func clearRealmDB() {
        // 이미지 전체 삭제
        let trackData = RealmService.shared.realm.objects(TrackData.self)
        for index in 0..<trackData.count {
            deleteImageFromDocumentDirectory(imageName: trackData[index]._id.stringValue)
        }
        
        // 데이터 전체 삭제
        let trackPoint = TrackPoint()
        RealmService.shared.deleteAll(trackPoint)
    }
    
    // 지도 종류 설정을 위한 Action 구성
    func getActionForMapType() -> UIAlertController {
        let actionSheet = UIAlertController(
            title: "지도 종류 선택", message: nil, preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(
            UIAlertAction(title: "표준", style: .default, handler: { _ in
                self.userDefaults.set(0, forKey: "mapType")
                self.shouldReloadTableView.onNext(true)
            })
        )
        actionSheet.addAction(
            UIAlertAction(title: "위성", style: .default, handler: { _ in
                self.userDefaults.set(1, forKey: "mapType")
                self.shouldReloadTableView.onNext(true)
            })
        )
        actionSheet.addAction(
            UIAlertAction(title: "하이브리드", style: .default, handler: { _ in
                self.userDefaults.set(2, forKey: "mapType")
                self.shouldReloadTableView.onNext(true)
            })
        )
        actionSheet.addAction(
            UIAlertAction(title: "취소", style: .cancel, handler: nil)
        )
        
        return actionSheet
    }
    
    // 목적지 경로 기준 설정을 위한 Action 구성
    func getActionForMapRadius() -> UIAlertController {
        let actionSheet = UIAlertController(
            title: "지도 표시 범위 선택", message: nil, preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(
            UIAlertAction(title: "사용자 중심 200 m", style: .default, handler: { _ in
                self.userDefaults.set(0.2, forKey: "mapRadius")
                self.shouldReloadTableView.onNext(true)
                NotificationCenter.default.post(name: Notification.Name("mapRadius"), object: nil)
            })
        )
        actionSheet.addAction(
            UIAlertAction(title: "사용자 중심 300 m", style: .default, handler: { _ in
                self.userDefaults.set(0.3, forKey: "mapRadius")
                self.shouldReloadTableView.onNext(true)
                NotificationCenter.default.post(name: Notification.Name("mapRadius"), object: nil)
            })
        )
        actionSheet.addAction(
            UIAlertAction(title: "사용자 중심 500 m", style: .default, handler: { _ in
                self.userDefaults.set(0.5, forKey: "mapRadius")
                self.shouldReloadTableView.onNext(true)
                NotificationCenter.default.post(name: Notification.Name("mapRadius"), object: nil)
            })
        )
        actionSheet.addAction(
            UIAlertAction(title: "사용자 중심 1 km", style: .default, handler: { _ in
                self.userDefaults.set(1.0, forKey: "mapRadius")
                self.shouldReloadTableView.onNext(true)
                NotificationCenter.default.post(name: Notification.Name("mapRadius"), object: nil)
            })
        )
        actionSheet.addAction(
            UIAlertAction(title: "사용자 중심 2 km", style: .default, handler: { _ in
                self.userDefaults.set(2.0, forKey: "mapRadius")
                self.shouldReloadTableView.onNext(true)
                NotificationCenter.default.post(name: Notification.Name("mapRadius"), object: nil)
            })
        )
        actionSheet.addAction(
            UIAlertAction(title: "취소", style: .cancel, handler: nil)
        )
        
        return actionSheet
    }
    
    // MY산책길 데이터 초기화를 위한 Action 구성
    func getActionForDBRemoval() -> UIAlertController {
        // 진짜로 취소할 것인지 alert message 보여주고 확인받기
        let alert = UIAlertController(
            title: "확인",
            message: "MY산책길 데이터를 모두 초기화할까요?\n삭제한 데이터는 복구할 수 없습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "아니요", style: .default)
        )
        alert.addAction(
            UIAlertAction(title: "네", style: .destructive) { _ in
                self.clearRealmDB()
                
                let indicatorView = SPIndicatorView(title: "삭제 완료", preset: .done)
                indicatorView.present(duration: 2.0, haptic: .success)
                
                // Tab Bar 뱃지의 숫자 업데이트 알리기
                NotificationCenter.default.post(name: Notification.Name("updateBadge"), object: nil)
                
                // userdefaults 값 false로 초기화 -> Lottie Animation 표출
                self.userDefaults.set(false, forKey: "myPlaceExist")
                NotificationCenter.default.post(name: Notification.Name("showLottieAnimation"), object: nil)
            }
        )
        
        return alert
    }
    
    // 현재 지도 종류를 나타낼 텍스트 가져오기
    func getLabelTextForMapType() -> String {
        let type = MKMapType(
            rawValue: UInt(self.userDefaults.integer(forKey: "mapType"))
        ) ?? .standard
        var labelString = ""
        
        if type == .standard {
            labelString = "표준"
        } else if type == .satellite {
            labelString = "위성"
        } else if type == .hybrid {
            labelString = "하이브리드"
        }
        
        return labelString
    }
    
    // 현재 지도 표시 범위를 나타낼 텍스트 가져오기
    func getLabelTextForMapRadius() -> String {
        let radius = self.userDefaults.double(forKey: "mapRadius")
        var labelString = ""
        
        if radius == 0.2 {
            labelString = "200 m"
        } else if radius == 0.3 {
            labelString = "300 m"
        } else if radius == 0.5 {
            labelString = "500 m"
        } else if radius == 1.0 {
            labelString = "1 km"
        } else if radius == 2.0 {
            labelString = "2 km"
        }
        
        return labelString
    }
 
    //MARK: - indirectly called method
    
    private func deleteImageFromDocumentDirectory(imageName: String) {
        // 1. 폴더 경로 가져오기
        guard let documentDirectory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
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
