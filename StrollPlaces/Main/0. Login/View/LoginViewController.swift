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
    
    //MARK: - Other property
    
    private let viewModel = LoginViewModel()
    private let isSignInAllowed = PublishSubject<Bool>()
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupAutomaticLogin()
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        self.navigationController?.applyDefaultSettings(hideBar: true)
    }
    
    // 자동로그인 설정
    private func setupAutomaticLogin() {
        self.view.addSubview(activityIndicator)
        self.activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        let isUserAlreadySignedUp = UserDefaults.standard.bool(forKey: K.UserDefaults.signUpStatus)
        let isUserAlreadyLoggedIn = UserDefaults.standard.bool(forKey: K.UserDefaults.signInStatus)
        
        print("isUserAlreadySignedUp: \(isUserAlreadySignedUp)")
        print("isUserAlreadyLoggedIn: \(isUserAlreadyLoggedIn)")
        
        // 회원 가입된 사용자가 로그인 되어있는 경우에만 바로 다음화면으로 넘어가도록 설정
        if isUserAlreadySignedUp && isUserAlreadyLoggedIn {
            // 로그인 버튼 비활성화 및 로딩 애니메이션 활성화
            DispatchQueue.main.async {
                self.googleLoginButton.isUserInteractionEnabled = false
                self.appleLoginButton.isUserInteractionEnabled = false
                self.activityIndicator.startAnimating()
            }
            
            // 로딩 애니메이션 비활성화 및 다음 화면으로 이동
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
        self.isSignInAllowed.asObservable()
            .filter { $0 == true }
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
    
    // Request authorization for sign-in.
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
            let request = AuthorizationService.shared.appleIDRequest
            
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
    
    // Apple Login (3): Apple 계정 인증 성공 시 실행할 내용
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        
        // 📌 Step 1: After success of authorization, retrieve user information from Apple ID Server.
        // (https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api/authenticating_users_with_sign_in_with_apple#3383773)
        
        // 인증 성공 이후 제공되는 정보
        switch authorization.credential {
            
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // Info #1: Identifier (unique to the user and never changing)
            let userIdentifier = appleIDCredential.user
            
            // Info #2: Name
            if let fullName = appleIDCredential.fullName {
                if let givenName = fullName.givenName,
                   let familyName = fullName.familyName {
                    UserDefaults.standard.setValue("\(givenName) \(familyName)", forKey: K.UserDefaults.userName)
                    print("user name: \(givenName) \(familyName)")
                }
            }
            
            // Info #3: Email
            if let userEmail = appleIDCredential.email {
                UserDefaults.standard.setValue(userEmail, forKey: K.UserDefaults.userEmail)
                print("user email: \(userEmail)")
            } else {
                guard let tokenString = String(data: appleIDCredential.identityToken ?? Data(), encoding: .utf8) else { return }
                let userEmail = AuthorizationService.shared.decode(jwtToken: tokenString)["email"] as? String ?? ""
                print("user email: \(userEmail)")
            }
            
            // ⭐️ The authorization code is disposable and valid for only 5 minutes after authentication.
            if let authorizationCode = appleIDCredential.authorizationCode,
               let identityToken = appleIDCredential.identityToken,
               let authCodeString = String(data: authorizationCode, encoding: .utf8),
               let identifyTokenString = String(data: identityToken, encoding: .utf8) {
                print("🗝 authrizationCode - \(authCodeString)")
                print("🗝 identifyToken - \(identifyTokenString)")
            }
            
            // 📌 Step 2: Returns the credential state for the given user to handle in a completion handler.
            // (https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api/verifying_a_user#3383776)
            ASAuthorizationAppleIDProvider()
                .getCredentialState(forUserID: userIdentifier) { credentialState, error in
                    switch credentialState {
                    case .authorized:
                        // Create and save client secret (JWT) in UserDefaults for later token revocation.
                        AuthorizationService.shared.createJWT()
                        // If sign-in is allowed, emit true element.
                        self.isSignInAllowed.onNext(true)
                        
                        // The Apple ID credential is valid. Show Home UI Here
                        print("credentialState: authorized")
                        UserDefaults.standard.setValue(true, forKey: K.UserDefaults.signInStatus)
                    
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
            
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("Username: \(username)")
            print("Password: \(password)")
            
            // Create and save client secret (JWT) in UserDefaults for later token revocation.
            AuthorizationService.shared.createJWT()
            // If sign-in is allowed, emit true element.
            self.isSignInAllowed.onNext(true)
            
        default:
            break
            
        }

    }
    
    // Apple 로그인 실패 시 실행할 내용
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        SPIndicatorService.shared.showErrorIndicator(title: "로그인 실패", message: "인증 취소됨")
    }
    
}
