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
    
    //MARK: - property
    
    internal let viewModel = MoreViewModel()
    private let isSignoutAllowed = BehaviorSubject<Bool>(value: false)
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupTableView()
        self.setupUserProfile()
        self.setupUserLogoutProcess()
        self.setupUserSignoutProcess()
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
        
        self.viewModel.shouldReloadTableView.asObservable()
            .filter { $0 == true }
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
            })
            .disposed(by: rx.disposeBag)
    }
    
    // 사용자 프로필 설정
    private func setupUserProfile() {
        self.profileBackView.backgroundColor = #colorLiteral(red: 0.9855152965, green: 0.4191898108, blue: 0.6166006327, alpha: 1)
        
        self.viewModel.userNickname
            .bind(to: self.nicknameLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    // 로그아웃 설정
    private func setupUserLogoutProcess() {
        // 애플 로그아웃을 시도한 경우 (AlertAction에서 "네"를 선택한 경우)
        self.viewModel.startLogout
            .filter { $0 == true }
            .flatMap { _ -> Observable<Bool> in
                return self.viewModel.requestFirebaseSignout(viewController: self)
            }
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                UserDefaults.standard.setValue(true, forKey: K.UserDefaults.signupStatus)
                UserDefaults.standard.setValue(false, forKey: K.UserDefaults.loginStatus)
                self.performSegue(withIdentifier: "ToLoginViewController", sender: self)
            })
            .disposed(by: rx.disposeBag)
    }
    
    // 회원탈퇴 설정
    private func setupUserSignoutProcess() {
        // Apple Signout (1): 애플 회원탈퇴 메뉴를 클릭한 경우
        self.viewModel.startSignout.asObservable()
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.requestAuthorization(with: .apple)
                //self.viewModel.requestFirebaseAuthorization()
            })
            .disposed(by: rx.disposeBag)
        
        // Apple Signout (4): requestAuthorization()에서 회원탈퇴가 허용 되었을 경우
        self.isSignoutAllowed.asObservable()
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.makeRevokeEvent()
            })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - indirectly called method
    
    // Apple Signout (2): Apple ID 사용 중단 요청하기 전 계정 인증 요청
    private func requestAuthorization(with type: LoginType) {
        switch type {
        case .google:
            // 테스트용 코드 --------------
            //self.isLoginAllowed.onNext(true)

            guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController")
                    as? OnboardingViewController else { return }

            nextVC.modalPresentationStyle = .fullScreen
            nextVC.hero.isEnabled = true
            nextVC.hero.modalAnimationType = .selectBy(presenting: .zoom,
                                                       dismissing: .zoomOut)
            self.present(nextVC, animated: true, completion: nil)
            // ------------------------

        case .apple:
            // 1. OpenID authorization 요청에 필요한 객체 생성
            let request = self.viewModel.appleIDRequest

            // 2. 이 ViewController에서 로그인 창을 띄우기 위한 준비
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
            authorizationController.performRequests()
        }
    }

}

////MARK: - extension for ASAuthorizationControllerDelegate
//
extension MoreViewController: ASAuthorizationControllerDelegate {

    // Apple Signout (3): Apple ID 사용 중단 요청하기 전 계정 인증 성공시 실행할 내용
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

//        // 인증 성공 이후 제공되는 정보
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

        // Firebase에서도 인증 수행
        self.viewModel.requestFirebaseAuthorization()

        // 회원탈퇴가 허용되었을 경우 true 이벤트 방출
        self.isSignoutAllowed.onNext(true)
    }

    // Apple 로그아웃 실패시 실행할 내용
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }

}

//MARK: - extension for MFMailComposeViewControllerDelegate

extension MoreViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}