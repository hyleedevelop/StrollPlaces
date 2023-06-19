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
import Alamofire

final class MoreViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var profileBackView: UIView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Property
    
    internal let viewModel = MoreViewModel()
    private let authorizationCode = PublishSubject<String>()
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setupTableView()
        self.setupUserProfileView()
        self.setupSignOutProcess()
        self.setupRevocationProcess()
        self.viewModel.getUserNickname()
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
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        // Navigation Bar 기본 설정
        navigationController?.applyCustomSettings()
        
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
        
        self.viewModel.shouldTableViewReloaded.asObservable()
            .filter { $0 == true }
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
            })
            .disposed(by: rx.disposeBag)
    }
    
    // 사용자 프로필 설정
    private func setupUserProfileView() {
        self.profileBackView.backgroundColor = #colorLiteral(red: 0.9855152965, green: 0.4191898108, blue: 0.6166006327, alpha: 1)
        
        self.viewModel.userNickname.asDriver()
            .drive(self.nicknameLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    // 로그아웃 설정
    private func setupSignOutProcess() {
        // 로그아웃을 시도한 경우
        self.viewModel.isSignOutRequested.asObservable()
            .filter { $0 == true }
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.updateAccountStatus(signUp: true, signIn: false)
                self.performSegue(withIdentifier: "ToLoginViewController", sender: self)
            })
            .disposed(by: rx.disposeBag)
    }
    
    // 회원탈퇴 설정
    private func setupRevocationProcess() {
        // 계정 삭제 메뉴를 클릭 -> 인증 요청을 보냄
        self.viewModel.isRevocationRequested.asObservable()
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.requestAuthorization(with: .apple)
            })
            .disposed(by: rx.disposeBag)
        
        // 인증에 성공 -> 인증코드를 이용해 애플 서버에 refresh token을 요청함
        self.authorizationCode.asObservable()
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                AuthorizationService.shared.requestAppleRefreshToken(code: $0)
                // 저장되어있던 이메일 정보 삭제
                UserDefaults.standard.setValue(nil, forKey: K.UserDefaults.userEmail)
            })
            .disposed(by: rx.disposeBag)
        
        // secret key와 refresh token 요청에 성공하여 받은 데이터가 모두 준비됨
        // -> refresh token 취소를 요청함
        let clientSecret = Observable
            .just(UserDefaults.standard.string(forKey: K.UserDefaults.clientSecret) ?? "")
        let refreshToken = AuthorizationService.shared.decodedData.asObservable()
            .map { ($0?.refresh_token ?? "") as String }
        
        Observable
            .combineLatest(clientSecret, refreshToken)
            .subscribe(onNext: {
                AuthorizationService.shared.revokeRefreshToken(clientSecret: $0, token: $1)
            })
            .disposed(by: rx.disposeBag)
        
        // refresh token 취소에 성공 -> 로그인 화면으로 돌아가기
        AuthorizationService.shared.isRefreshTokenRevoked.asObservable()
            .filter { $0 == true }
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                //self.activityIndicator.stopAnimating()
                self.goToLoginViewController()
            })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - indirectly called method
    
    // Apple Signout (2): Apple ID 사용 중단 요청하기 전 계정 인증 요청
    private func requestAuthorization(with type: LoginType) {
        switch type {
        case .google:
            break

        case .apple:
            // Create an instance of ASAuthorizationAppleIDRequest.
            let request = AuthorizationService.shared.appleIDRequest
            
            // Preparing to display the sign-in view in LoginViewController.
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
            
            // Present the sign-in(or sign-up) view.
            authorizationController.performRequests()
        }
    }
    
    // If login process has successfully done, let's go to the HomeViewController.
    private func goToLoginViewController() {
        self.performSegue(withIdentifier: "ToLoginViewController", sender: self)
    }

}

//MARK: - extension for ASAuthorizationControllerDelegate

extension MoreViewController: ASAuthorizationControllerDelegate {

    // Apple Signout (3): Apple ID 사용 중단 요청하기 전 계정 인증 성공시 실행할 내용
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        // The information provided after successful authentication
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        // ⭐️ The authorization code is disposable and valid for only 5 minutes after authentication.
        if let authorizationCode = appleIDCredential.authorizationCode {
            let code = String(decoding: authorizationCode, as: UTF8.self)
            self.authorizationCode.onNext(code)
        }
    }

    // Apple 로그아웃 실패시 실행할 내용
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        SPIndicatorService.shared.showErrorIndicator(title: "로그아웃 실패", message: "인증 취소됨")
    }

}

//MARK: - extension for MFMailComposeViewControllerDelegate

extension MoreViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
