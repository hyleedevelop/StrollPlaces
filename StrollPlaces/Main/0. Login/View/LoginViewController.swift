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
import NVActivityIndicatorView
//import FirebaseAuth

final class LoginViewController: UIViewController {

    //MARK: - IB Outlet & Action
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        print("Unwinding to LoginViewController")
    }
    
    @IBOutlet weak var googleLoginButton: UIView!
    @IBOutlet weak var appleLoginButton: UIView!

    //MARK: - UI property
    
    // 로딩 아이콘
    private let activityIndicator: NVActivityIndicatorView = {
        let activityIndicator = NVActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: 40, height: 40),
            type: .ballPulseSync,
            color: K.Color.themeRed,
            padding: .zero)
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    
    //MARK: - normal property
    
    private let viewModel = LoginViewModel()
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupLoginProcess()
        self.setupButton()
        self.setupLoginProcess()
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        self.navigationController?.applyDefaultSettings(hideBar: true)
    }
    
    private func setupLoginProcess() {
        self.view.addSubview(activityIndicator)
        self.activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        let isUserAlreadyLoggedIn = UserDefaults.standard.bool(forKey: K.UserDefaults.loginStatus)
        
        // 사용자가 이미 로그인 되어있는 경우에만 바로 다음화면으로 넘어가도록 설정
        if isUserAlreadyLoggedIn {
            // 로그인 버튼 비활성화 및 로딩 애니메이션 활성화
            DispatchQueue.main.async {
                self.googleLoginButton.isUserInteractionEnabled = false
                self.appleLoginButton.isUserInteractionEnabled = false
                self.activityIndicator.startAnimating()
            }
            
            // 1초 뒤 로딩 애니메이션 비활성화 및 다음 화면으로 이동
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.activityIndicator.stopAnimating()
                self.googleLoginButton.isUserInteractionEnabled = true
                self.appleLoginButton.isUserInteractionEnabled = true
                self.viewModel.goToNextViewController(viewController: self)
            }
        }
    }
    
    // (뷰로 만든) 커스텀버튼 설정
    private func setupButton() {
        // UI 설정
        self.googleLoginButton.applySocialLoginButtonFormat()
        self.appleLoginButton.applySocialLoginButtonFormat()
        self.googleLoginButton.isUserInteractionEnabled = true
        self.appleLoginButton.isUserInteractionEnabled = true
        
        // Google Login (1): 구글 로그인을 시도한 경우
        self.googleLoginButton.rx.tapGesture()
            .when(.recognized)  // 바인딩 할때도 이벤트가 방출되므로 .when() 넣기
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // 구글 계정 인증 요청 보내기
                self.requestAuthorization(with: .google)
            })
            .disposed(by: rx.disposeBag)

        // Apple Login (1): 버튼을 눌러 애플 로그인을 시도한 경우
        self.appleLoginButton.rx.tapGesture()
            .when(.recognized)  // 바인딩 할때도 이벤트가 방출되므로 .when() 넣기
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // 애플 계정 인증 요청 보내기
                self.requestAuthorization(with: .apple)
            })
            .disposed(by: rx.disposeBag)
        
        // Apple Login (5): Firebase에서도 인증이 완료된 경우
        self.viewModel.isLoginAllowed.asObservable()
            .filter { $0 == true }
            .map { _ in self.activityIndicator.startAnimating() }
            .delay(.milliseconds(700), scheduler: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // 다음 화면으로 이동
                self.activityIndicator.stopAnimating()
                self.viewModel.goToNextViewController(viewController: self)
            })
            .disposed(by: rx.disposeBag)
    }

    //MARK: - indirectly called method
    
    // Apple Login (2): 로그인을 위한 인증 요청하기
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
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
    
}

//MARK: - extension for ASAuthorizationControllerDelegate

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    // 애플 로그인 창을 띄울 위치
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return self.view.window!
        }
    
    // Apple Login (3): Apple 계정 인증 성공 시 실행할 내용
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // 1. 사용자의 정보 가져오기
        
        // authorization: controller로부터 받은 인증 성공 정보에 대한 캡슐화된 객체
        K.Login.authorization = authorization
        
        var userIdentifier: String = ""
        var userEmail: String = ""
        
        // 인증 성공 이후 제공되는 정보
        switch authorization.credential {
            
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // (1) 사용자에 대한 고유 식별자 (항상 변하지 않는 값)
            userIdentifier = appleIDCredential.user
            UserDefaults.standard.setValue(userIdentifier, forKey: K.UserDefaults.userIdentifier)
            
            // (2) 사용자의 이름
            let fullName = appleIDCredential.fullName ?? PersonNameComponents()
            
            // (3) 사용자의 이메일
            userEmail = appleIDCredential.email ?? "no email"
            UserDefaults.standard.setValue(userEmail, forKey: K.UserDefaults.userEmail)
            
            // authorizationCode는 일회용이고 5분간 유효함
            if let authorizationCode = appleIDCredential.authorizationCode,
               let identityToken = appleIDCredential.identityToken,
               let authCodeString = String(data: authorizationCode, encoding: .utf8),
               let identifyTokenString = String(data: identityToken, encoding: .utf8) {
                let code = String(decoding: authorizationCode, as: UTF8.self)
                UserDefaults.standard.setValue(code, forKey: K.UserDefaults.authCode)
                
                print("AuthorizationCode: \(authorizationCode)")
                print("IdentityToken: \(identityToken)")
                print("AuthCodeString: \(authCodeString)")
                print("IdentifyTokenString: \(identifyTokenString)")
            }
            
            print("Useridentifier: \(userIdentifier)")
            print("FullName: \(fullName)")
            print("Email: \(userEmail)")
            
            // Apple Login (4): FirebaseAuth 인증 요청
            self.viewModel.requestFirebaseAuthorization(credential: appleIDCredential)
            
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("Username: \(username)")
            print("Password: \(password)")
            
        default:
            break
            
        }
        
        // 2. 사용자의 식별자를 이용해 경우에 따른 로그인 처리
        
        ASAuthorizationAppleIDProvider()
            .getCredentialState(forUserID: userIdentifier) { credentialState, error in
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

    }
    
    // Apple 로그인 실패 시 실행할 내용
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        SPIndicatorService.shared.showErrorIndicator(title: "로그인 실패", message: "인증 불가")
    }
    
}
