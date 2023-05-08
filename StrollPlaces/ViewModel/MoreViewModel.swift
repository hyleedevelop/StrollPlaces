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
import SettingsIconGenerator

final class MoreViewModel {
    
    //MARK: - property
    
    private let appSettings: [MoreCellData]!
    private let feedback: [MoreCellData]!
    private let aboutTheApp: [MoreCellData]!
    let moreCellData: [[MoreCellData]]!
    
    //MARK: - initializer
    
    init() {
        appSettings = [
            MoreCellData(icon: UIImage.generateSettingsIcon("map", backgroundColor: .systemBlue),
                         title: "지도", value: nil),
            MoreCellData(icon: UIImage.generateSettingsIcon("trash", backgroundColor: .systemRed),
                         title: "산책길 보관함 비우기", value: nil),
        ]

        feedback = [
            MoreCellData(icon: UIImage.generateSettingsIcon("star", backgroundColor: .systemGreen),
                         title: "앱 리뷰", value: nil),
            MoreCellData(icon: UIImage.generateSettingsIcon("envelope", backgroundColor: .systemRed),
                         title: "문의사항", value: nil),
        ]
        
        aboutTheApp = [
            MoreCellData(icon: UIImage.generateSettingsIcon("questionmark", backgroundColor: .systemBlue),
                         title: "도움말", value: nil),
            MoreCellData(icon: UIImage.generateSettingsIcon("wand.and.stars.inverse", backgroundColor: .systemRed),
                         title: "라이브러리", value: nil),
            MoreCellData(icon: UIImage.generateSettingsIcon("doc.text", backgroundColor: .systemGreen),
                         title: "개인정보 정책", value: nil),
            MoreCellData(icon: UIImage.generateSettingsIcon("doc.text", backgroundColor: .systemRed),
                         title: "이용약관", value: nil),
            MoreCellData(icon: UIImage.generateSettingsIcon("number", backgroundColor: .systemBlue),
                         title: "버전", value: nil),
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



