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
import SafariServices
import MessageUI

final class MoreViewModel {
    
    //MARK: - 생성자
    
    private let appSettings: [MoreCellData]!
    private let feedback: [MoreCellData]!
    private let aboutTheApp: [MoreCellData]!
    let moreCellData: [[MoreCellData]]!
    
    init() {
        appSettings = [
            MoreCellData(title: "지도 종류", value: nil),
            MoreCellData(title: "지도 표시 범위", value: nil),
            MoreCellData(title: "즐겨찾기 데이터 초기화", value: nil),
            MoreCellData(title: "MY산책길 데이터 초기화", value: nil),
        ]

        feedback = [
            MoreCellData(title: "앱 리뷰", value: nil),
            MoreCellData(title: "문의사항", value: nil),
        ]
        
        aboutTheApp = [
            MoreCellData(title: "도움말", value: nil),
            MoreCellData(title: "개인정보 정책", value: nil),
            MoreCellData(title: "이용약관", value: nil),
            MoreCellData(title: "버전", value: nil),
        ]
        
        moreCellData = [appSettings, feedback, aboutTheApp]
    }
    
    //MARK: - 앱 설정 관련
    
    private let userDefaults = UserDefaults.standard
    let shouldReloadTableView = BehaviorSubject<Bool>(value: false)
    
    // 현재 지도 표시 범위를 나타낼 텍스트
    var labelTextForMapRadius: String {
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
    
    // 현재 지도 종류를 나타낼 텍스트
    var labelTextForMapType: String {
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
    
    //MARK: - 앱 및 유저 디바이스 정보 관련
    
    // 앱 이름
    var appName: String {
        if let bundleDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return bundleDisplayName
        } else if let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return bundleName
        } else {
            return "알수없음"
        }
    }
    
    // 앱 버전
    var appVersion: String {
        if let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return bundleVersion
        } else {
            return "알수없음"
        }
    }
    
    // 앱 빌드넘버
    var buildNumber: String {
        if let bundleBuildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            return bundleBuildNumber
        } else {
            return "알수없음"
        }
    }
    
    // 사용자의 기기 이름
    var device: String {
        var modelName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] ?? ""
        let myDevice = UIDevice.current
        let selName = "_\("deviceInfo")ForKey:"
        let selector = NSSelectorFromString(selName)

        if myDevice.responds(to: selector) {
            modelName = String(describing: myDevice.perform(selector, with: "marketing-name").takeRetainedValue())
            return modelName
        } else {
            return "알수없음"
        }
    }
    
    // 사용자의 기기 OS 버전
    let iOSVersion = UIDevice.current.systemVersion
    
    //MARK: - TableView Cell 관련
    
    // section의 개수
    let numberOfSections: Int = MoreCellSection.allCases.count
    
    // section당 row의 개수
    func numberOfRowsInSection(at section: Int) -> Int {
        return moreCellData[section].count
    }
    
    // header 높이
    func headerHeight(at section: Int) -> CGFloat {
        return section == 0 ? 50 : 40
    }
    
    // footer 높이
    let footerHeight: CGFloat = 40
    
    // cell 높이
    let cellHeight: CGFloat = 44
    
    // custom header view
    func headerInSection(tableView: UITableView, at section: Int) -> UIView? {
        let yPosition: CGFloat = section == 0 ? 20 : 10
        let titleLabel = UILabel(frame: CGRect(
            x: 10, y: yPosition, width: tableView.frame.width, height: 18
        ))
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor.black
        titleLabel.text = self.titleForHeaderInSection(at: section)
        
        let headerView = UIView()
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    // 텍스트 정보
    private func titleForHeaderInSection(at section: Int) -> String? {
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
    
    // custom footer view
    func footerInSection(tableView: UITableView, at section: Int) -> UIView? {
        let separatorView = UIView(frame: CGRect(
            x: -20, y: 20, width: tableView.frame.width, height: 1
        ))
        separatorView.backgroundColor = UIColor.systemGray5
        
        let footerView = UIView()
        footerView.addSubview(separatorView)
        
        return section == self.numberOfSections-1 ? nil : footerView
    }
    
    //MARK: - Action 관련
    
    // 지도 종류 설정을 위한 Action 구성
    var actionForMapType: UIAlertController {
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
    var actionForMapRadius: UIAlertController {
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
    var actionForDBRemoval: UIAlertController {
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
                self.clearMyPlaceDB()
                SPIndicatorService.shared.showSuccessIndicator(title: "초기화 완료")
                
                // Tab Bar 뱃지의 숫자 업데이트 알리기
                NotificationCenter.default.post(name: Notification.Name("updateBadge"), object: nil)
                
                // userdefaults 값 false로 초기화 -> Lottie Animation 표출
                self.userDefaults.set(false, forKey: "myPlaceExist")
                NotificationCenter.default.post(name: Notification.Name("showLottieAnimation"), object: nil)
            }
        )
        
        return alert
    }
    
    // 즐겨찾기 데이터 초기화를 위한 Action 구성
    var actionForMarkRemoval: UIAlertController {
        // 진짜로 취소할 것인지 alert message 보여주고 확인받기
        let alert = UIAlertController(
            title: "확인",
            message: "즐겨찾기 데이터를 모두 초기화할까요?\n삭제한 데이터는 복구할 수 없습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "아니요", style: .default)
        )
        alert.addAction(
            UIAlertAction(title: "네", style: .destructive) { _ in
                self.clearMarkDB()
                SPIndicatorService.shared.showSuccessIndicator(title: "초기화 완료")
            }
        )
        
        return alert
    }
    
    // 추후 업데이트 예정이라는 Alert Message 표시
    func showWillBeUpdatedMessage(viewController: UIViewController) {
        let alert = UIAlertController(title: K.More.sorryTitle,
                                      message: K.More.notifyLaterUpdateMessage,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    // 문의사항 메뉴 클릭 시 이메일 쓰기
    func contactMenuTapped(viewController: UIViewController) {
        if MFMailComposeViewController.canSendMail() {
            let compseViewController = MFMailComposeViewController()
            compseViewController.mailComposeDelegate = (viewController as! any MFMailComposeViewControllerDelegate)
            compseViewController.setToRecipients([K.Message.emailAddress])
            compseViewController.setSubject("[App Contact Email] ")
            compseViewController.setMessageBody(self.messageBody, isHTML: false)

            viewController.present(compseViewController, animated: true, completion: nil)
        }
        else {
            let sendMailErrorAlert = UIAlertController(title: K.Message.errorTitle,
                                                       message: K.Message.sendEmailErrorMessage,
                                                       preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "OK", style: .default)
            sendMailErrorAlert.addAction(confirmAction)
            viewController.present(sendMailErrorAlert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Realm DB 관련
    
    // MY산책길 관련 Realm DB 삭제
    func clearMyPlaceDB() {
        // 폴더 내 지도 이미지 삭제
        let trackData = RealmService.shared.realm.objects(TrackData.self)
        for index in 0..<trackData.count {
            deleteImageFromDocumentDirectory(imageName: trackData[index]._id.stringValue)
        }
        
        // 오브젝트 내 데이터 삭제
        RealmService.shared.deleteTrack()
    }
    
    // 즐겨찾기 관련 Realm DB 삭제
    func clearMarkDB() {
        // 오브젝트 내 데이터 삭제
        RealmService.shared.deleteMyPlace()
        
        // MapView 갱신 알리기
        NotificationCenter.default.post(name: Notification.Name("reloadMap"), object: nil)
    }
    
    // Document 폴더에 위치한 이미지 삭제
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
    
    //MARK: - 이메일/브라우저 관련
    
    // 메일 기본 양식
    var messageBody: String {
        return "* My Info *" + "\n" +
        "App name: \(self.appName)" + "\n" +
        "App version: \(self.appVersion) (\(self.buildNumber))" + "\n" +
        "Device name: \(self.device)" + "\n" +
        "Device OS version: \(self.iOSVersion)" + "\n"
    }
    
    // 사파리로 웹페이지 연결
    func showSafariView(viewController: UIViewController, urlString: String) {
        let websiteURL = NSURL(string: urlString)
        let webView = SFSafariViewController(url: websiteURL! as URL)
        viewController.present(webView, animated: true, completion: nil)
    }
    
}
