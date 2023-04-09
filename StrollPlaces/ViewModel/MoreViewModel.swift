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

final class MoreViewModel {
    
    //MARK: - property
    
    private let appSettings: [MoreCellData]!
    private let feedback: [MoreCellData]!
    private let aboutTheApp: [MoreCellData]!
    let moreCellData: [[MoreCellData]]!
    
    //MARK: - initializer
    
    init() {
        appSettings = [
            MoreCellData(icon: UIImage(systemName: "paintbrush"), title: "지도", value: nil),
            MoreCellData(icon: UIImage(systemName: "paintbrush"), title: "경로안내", value: nil),
            MoreCellData(icon: UIImage(systemName: "paintbrush"), title: "산책길 보관함 비우기", value: nil),
        ]

        feedback = [
            MoreCellData(icon: UIImage(systemName: "star"), title: "앱 리뷰", value: nil),
            MoreCellData(icon: UIImage(systemName: "envelope"), title: "문의사항", value: nil),
        ]
        
        aboutTheApp = [
            MoreCellData(icon: UIImage(systemName: "questionmark.circle"), title: "도움말", value: nil),
            MoreCellData(icon: UIImage(systemName: "wand.and.stars.inverse"), title: "라이브러리", value: nil),
            MoreCellData(icon: UIImage(systemName: "doc.text"), title: "개인정보 정책", value: nil),
            MoreCellData(icon: UIImage(systemName: "doc.text"), title: "이용약관", value: nil),
            MoreCellData(icon: UIImage(systemName: "number.circle"), title: "버전", value: nil),
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
        let trackPoint = TrackPoint()
        RealmService.shared.deleteAll(trackPoint)
    }
    
}



