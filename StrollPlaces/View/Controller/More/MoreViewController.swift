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
import AcknowList
import MessageUI
//import GoogleMobileAds
//import StoreKit

class MoreViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var bannerView: GADBannerView!
    
    //MARK: - property
    
    internal let viewModel = MoreViewModel()
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundColor = UIColor.white
//        navigationBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        // scrollEdge: 스크롤 하기 전의 NavigationBar
        // standard: 스크롤을 하고 있을 때의 NavigationBar
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNeedsStatusBarAppearanceUpdate()

        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    // TableView 설정
    private func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    //MARK: - indirectly called method
    
    
    
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
