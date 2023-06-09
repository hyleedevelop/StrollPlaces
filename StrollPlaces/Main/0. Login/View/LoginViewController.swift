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

    //MARK: - IB Action
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        print("Unwinding to LoginViewController")
    }
    
    //MARK: - normal property
    
    private let viewModel = LoginViewModel()
    private let isLoginAllowed = BehaviorSubject<Bool>(value: false)
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupButton()
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        self.navigationController?.applyDefaultSettings(hideBar: true)
    }
    
    // (뷰로 만든) 커스텀버튼 설정
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
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.goToNextViewController(viewController: self)
            })
            .disposed(by: rx.disposeBag)
    }

    //MARK: - indirectly called method
    
    // 로그인을 위한 인증 요청하기
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

//MARK: - extension for ASAuthorizationControllerDelegate

extension LoginViewController: ASAuthorizationControllerDelegate {

    // requestAuthorization() 메서드에서 Apple 로그인 성공 시 실행할 내용
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // 1. 사용자의 정보 가져오기
        
        K.Login.authorization = authorization
        
        // 인증 성공 이후 제공되는 정보
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        // 사용자에 대한 고유 식별자 (항상 변하지 않는 값)
        let userIdentifier = appleIDCredential.user
        // 사용자의 이름
        let fullName = appleIDCredential.fullName ?? PersonNameComponents()
        // 사용자의 이메일
        let email = appleIDCredential.email ?? "없음"
        
        // authorizationCode는 일회용이고 5분간 유효함
        if let authorizationCode = appleIDCredential.authorizationCode,
           let identityToken = appleIDCredential.identityToken,
           let authCodeString = String(data: authorizationCode, encoding: .utf8),
           let identifyTokenString = String(data: identityToken, encoding: .utf8) {
            // UserDefaults에 저장했다가 나중에 회원탈퇴 시 활용
            let code = String(decoding: authorizationCode, as: UTF8.self)
            //UserDefaults.standard.setValue(code, forKey: "theAuthorizationCode")
            UserDefaults.standard.setValue(code, forKey: "theAuthorizationCode")
            print("Code - \(code)")
            
//            self.viewModel.getAppleRefreshToken(code: code) { data in
//                UserDefaults.standard.set(data.refresh_token, forKey: "AppleRefreshToken")
//            }
            
            print("authorizationCode: \(authorizationCode)")
            print("identityToken: \(identityToken)")
            print("authCodeString: \(authCodeString)")
            print("identifyTokenString: \(identifyTokenString)")
        }
        
        print("useridentifier: \(userIdentifier)")
        print("fullName: \(fullName)")
        print("email: \(email)")

        // 2. 사용자의 식별자를 이용해 경우에 따른 로그인 처리
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userIdentifier) { credentialState, error in
            switch credentialState {
            case .authorized:
                // The Apple ID credential is valid. Show Home UI Here
                print("credentialState: authorized")
            case .revoked:
                // The Apple ID credential is revoked. Show SignIn UI Here.
                print("credentialState: revoked")
            case .notFound:
                // No credential was found. Show SignIn UI Here.
                print("credentialState: notFound")
                break
            default:
                break
            }
        }
        
        // Firebase에서도 인증 수행
        self.viewModel.requestFirebaseAuthorization(credential: appleIDCredential)
        
        // 로그인이 허용되었을 경우 true 이벤트 방출
        self.isLoginAllowed.onNext(true)
    }
    
    // Apple 로그인 실패 시 실행할 내용
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.viewModel.showErrorMessage()
    }
    
}
