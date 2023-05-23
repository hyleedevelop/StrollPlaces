//
//  SettingViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SafariServices
import MessageUI

final class MoreViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - property
    
    internal let viewModel = MoreViewModel()
    internal let userDefaults = UserDefaults.standard
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Navigation Bar 기본 설정
        navigationController?.applyCommonSettings()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Navigation Bar 기본 설정
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        // Navigation Bar 기본 설정
        navigationController?.applyCommonSettings()
        
        // 좌측 상단에 위치한 타이틀 설정
        navigationItem.makeLeftSideTitle(title: "더보기")
    }
    
    // TableView 설정
    private func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "MoreTableViewCell", bundle: nil),
                                forCellReuseIdentifier: "MoreCell")
        self.tableView.backgroundColor = UIColor.white
        self.tableView.separatorStyle = .none
        //self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        self.viewModel.shouldReloadTableView.asObservable()
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] needToBeReloaded in
                guard let self = self else { return }
                if needToBeReloaded { self.tableView.reloadData() }
            })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - indirectly called method
    
    internal func showSafariView(urlString: String) {
        let websiteURL = NSURL(string: urlString)
        let webView = SFSafariViewController(url: websiteURL! as URL)
        self.present(webView, animated: true, completion: nil)
    }
    
    // 추후 업데이트 예정이라는 Alert Message 출력하기
    internal func showWillBeUpdatedMessage() {
        let alert = UIAlertController(title: K.More.sorryTitle,
                                      message: K.More.notifyLaterUpdateMessage,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - extension for MFMailComposeViewControllerDelegate

extension MoreViewController: MFMailComposeViewControllerDelegate {

    private func contactMenuTapped() {
        if MFMailComposeViewController.canSendMail() {
            // 앱 이름 저장
            var appName: String? {
                if let bundleDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
                    return bundleDisplayName
                } else if let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
                    return bundleName
                }
                return nil
            }

            // 앱 버전 저장
            var appVersion: String? {
                if let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                    return bundleVersion
                } else {
                    return nil
                }
            }

            // 기기 이름 저장
            var device: String? {
                var modelName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] ?? ""
                let myDevice = UIDevice.current
                let selName = "_\("deviceInfo")ForKey:"
                let selector = NSSelectorFromString(selName)

                if myDevice.responds(to: selector) {
                    modelName = String(describing: myDevice.perform(selector, with: "marketing-name").takeRetainedValue())
                    return modelName
                } else {
                    return nil
                }
            }

            // 기기 OS 버전 저장
            let iOSVersion = UIDevice.current.systemVersion

            let messageBody: String = "* My Info *" + "\n" +
                                      "App name: \(appName ?? "N/A")" + "\n" +
                                      "App version: \(appVersion ?? "N/A")" + "\n" +
                                      "Device name: \(device ?? "N/A")" + "\n" +
                                      "Device OS version: \(iOSVersion)" + "\n"

            let compseViewController = MFMailComposeViewController()
            compseViewController.mailComposeDelegate = self
            compseViewController.setToRecipients(["hyleedevelop@gmail.com"])
            compseViewController.setSubject("[App Contact Email] ")
            compseViewController.setMessageBody(messageBody, isHTML: false)

            self.present(compseViewController, animated: true, completion: nil)
        }
        else {
            let sendMailErrorAlert = UIAlertController(title: K.Message.errorTitle,
                                                       message: K.Message.sendEmailErrorMessage,
                                                       preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "OK", style: .default)
            sendMailErrorAlert.addAction(confirmAction)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
