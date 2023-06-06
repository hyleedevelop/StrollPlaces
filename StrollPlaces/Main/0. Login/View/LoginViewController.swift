//
//  LoginViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/04.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import NSObject_Rx
import AuthenticationServices
//import FirebaseAuth

final class LoginViewController: UIViewController {

    //MARK: - UI property
    
    @IBOutlet weak var googleLoginButton: UIView!
    @IBOutlet weak var appleLoginButton: UIView!
    
    //MARK: - normal property
    
    private let viewModel = LoginViewModel()
    private let isLoginAllowed = BehaviorSubject<Bool>(value: false)
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupButton()
    }
    
    deinit {
        print("LoginViewController 메모리 해제됨")
    }
    
    //MARK: - IBAction
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        print("unwinding to LoginViewController...")
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        self.navigationController?.applyDefaultSettings(hideBar: true)
    }
    
    // 각종 버튼 설정
    private func setupButton() {
        // 구글 로그인을 시도한 경우
        self.googleLoginButton.applySocialLoginButtonFormat()
        self.googleLoginButton.rx.tapGesture()
            .when(.recognized)  // 바인딩 할때도 이벤트가 방출되므로 .when() 넣기
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.requestAuthorization(with: .google)
            })
            .disposed(by: rx.disposeBag)

        // 애플 로그인을 시도한 경우
        self.appleLoginButton.applySocialLoginButtonFormat()
        self.appleLoginButton.rx.tapGesture()
            .when(.recognized)  // 바인딩 할때도 이벤트가 방출되므로 .when() 넣기
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.requestAuthorization(with: .apple)
            })
            .disposed(by: rx.disposeBag)
        
        // 로그인이 허용 되었을 경우
        self.isLoginAllowed.asObservable()
            .subscribe(onNext: { [weak self] allowed in
                guard let self = self else { return }
                if allowed {
                    self.viewModel.goToNextViewController(viewController: self)
                } else {
                    self.viewModel.showAlertMessage(success: false)
                }
            })
            .disposed(by: rx.disposeBag)
    }

    //MARK: - indirectly called method
    
    // 소셜 로그인 요청하기
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
            let request = self.viewModel.appleIDRequest
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
            authorizationController.performRequests()
        }
    }
    
}

//MARK: - extension for ASAuthorizationControllerDelegate

extension LoginViewController: ASAuthorizationControllerDelegate {

    // Apple 로그인 인증 성공시 실행할 내용
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

        /*
        // 이메일 (맨 처음 시도) 가져오기
        if let email = credential.email {
            print(email)

        // 이메일 (두번째 시도부터) 가져오기
        } else {
            // credential.identityToken은 jwt로 되어있고, 해당 토큰을 decode 후 email에 접근해야한다.
            guard let tokenString = String(data: credential.identityToken ?? Data(), encoding: .utf8) else { return }
            let email = self.viewModel.decode(jwtToken: tokenString)["email"] as? String ?? ""
            print(email)
        }

        // 이름 가져오기
        if let fullName = credential.fullName {
            let name = "\(fullName.familyName ?? "") \(fullName.givenName ?? "")"
            print(name)
        }
        
        // 사용자 정보
        let userIdentifier = credential.user
        let userName = credential.fullName
        let userEmail = credential.email
         */
         
        // Firebase 인증 수행
        self.viewModel.requestFirebaseAuthorization(credential: credential)
        
        // 로그인이 허용되었을 경우 true 이벤트 방출
        self.isLoginAllowed.onNext(true)
    }
    
    // Apple 로그인 인증 실패시 실행할 내용
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.viewModel.showAlertMessage(success: false)
    }
    
}
