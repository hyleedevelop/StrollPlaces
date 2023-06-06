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
import AuthenticationServices

final class MoreViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - property
    
    internal let viewModel = MoreViewModel()
    internal let userDefaults = UserDefaults.standard
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupLabel()
        self.setupTableView()
        self.setupUserLogout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Navigation Bar 기본 설정
        navigationController?.applyCustomSettings()
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
        navigationController?.applyCustomSettings()
        
        // 좌측 상단에 위치한 타이틀 설정
        navigationItem.makeLeftSideTitle(title: "더보기")
    }
    
    // Label 설정
    private func setupLabel() {
        self.viewModel.nicknameString
            .bind(to: self.nicknameLabel.rx.text)
            .disposed(by: rx.disposeBag)
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
            .filter { $0 == true }
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
            })
            .disposed(by: rx.disposeBag)
    }
    
    // 사용자 로그아웃 설정
    private func setupUserLogout() {
        self.viewModel.logoutSubject
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.requestFirebaseRevoke(viewController: self)
                //self.deleteCurrentUser(with: .apple)
            })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - indirectly called method
    
    // 소셜 로그인 요청하기
    func deleteCurrentUser(with type: LoginType) {
        switch type {
        case .google:
            break

        case .apple:
            let request = self.viewModel.appleIDRequest
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
            authorizationController.performRequests()
            
            //self.viewModel.goToSplashViewController(viewController: self)
        }
    }
    
}

//MARK: - extension for MFMailComposeViewControllerDelegate

extension MoreViewController: MFMailComposeViewControllerDelegate {

    

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//MARK: - extension for ASAuthorizationControllerDelegate

extension MoreViewController: ASAuthorizationControllerDelegate {

    // Apple 로그아웃 성공시 실행할 내용
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
    }
    
    // Apple 로그아웃 실패시 실행할 내용
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }
    
}
