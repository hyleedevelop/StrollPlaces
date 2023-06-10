//
//  LoginViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/04.
//

import UIKit
import CryptoKit
import RxSwift
import SkyFloatingLabelTextField
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore
import Alamofire

final class LoginViewModel {

    //MARK: - 속성 관련
    
    private let userDefaults = UserDefaults.standard
    var currentNonce: String?
    let isUserAlreadySignedUp = BehaviorSubject<Bool>(value: false)
    let isLoginAllowed = BehaviorSubject<Bool>(value: false)
    
    //MARK: - 생성자 관련
    
    init() {
        
    }
    
    //MARK: - 애플 로그인 관련
    
    var appleIDRequest: ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        let nonce = CryptoService.shared.randomNonceString()
        
        request.requestedScopes = [.fullName, .email]
        request.nonce = CryptoService.shared.sha256(nonce)
        self.currentNonce = nonce
        
        return request
    }
    
    //MARK: - Firebase 관련
    
    func requestFirebaseAuthorization(credential: ASAuthorizationAppleIDCredential) {
        // 1. 현재 nonce가 설정되어 있는지 확인
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        
        // 2. ID 토큰 검색
        guard let appleIDtoken = credential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        
        // 3. 토큰을 문자열로 변환
        guard let idTokenString = String(data: appleIDtoken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDtoken.debugDescription)")
            return
        }
        
        // 4. OAuthProvider에게 방금 로그인한 사용자를 나타내는 credential을 생성하도록 요청
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce
        )
        
        // 5. credential을 이용해 Firebase에 로그인 요청
        FirebaseAuth.Auth.auth().signIn(with: credential) { (authDataResult, error) in
            // 인증 결과에서 Firebase 사용자를 검색하고 사용자 정보를 표시할 수 있다.
            if let user = authDataResult?.user {
                print("애플 로그인 성공!", user.uid, user.email ?? "-")
                self.isLoginAllowed.onNext(true)
            }
            
            if error != nil {
                print(error?.localizedDescription ?? "error" as Any)
                return
            }
        }
        
    }
    
    // 사용자의 이메일 값을 이용해 닉네임 값을 가져와서 Relay의 이벤트로 방출
    private func checkUserEmail() {
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        
        Firestore
            .firestore()
            .collection(K.Login.collectionName)
            .document(userEmail)
            .getDocument { document, error in
                guard let nickname = document?.get(K.Login.nicknameField) as? String else { return }
                //self.isUserAlreadySignedUp.onNext(nickname)
            }
    }
    
    //MARK: - 화면 이동 관련
    
    // 다음 화면으로 이동
    func goToNextViewController(viewController: UIViewController) {
        let isUserAlreadySignedUp = UserDefaults.standard.bool(forKey: K.UserDefaults.signupStatus)
        let isUserAlreadyLoggedIn = UserDefaults.standard.bool(forKey: K.UserDefaults.loginStatus)
        let hideOnboarding = UserDefaults.standard.bool(forKey: K.UserDefaults.hideOnboarding)
        
        print("사용자가 이미 회원가입 되어 있습니까?: \(isUserAlreadySignedUp)")
        print("사용자가 이미 로그인 되어 있습니까?: \(isUserAlreadyLoggedIn)")
        print("앱 사용방법 설명이 필요없습니까?: \(hideOnboarding)")
        
        if isUserAlreadySignedUp || isUserAlreadyLoggedIn {
            if hideOnboarding {
                // (1) 유저가 이미 등록되어 있고, 앱 사용방법 설명이 필요 없는 경우
                
                guard let nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "UITabBarController") as? UITabBarController else { return }
                nextVC.modalPresentationStyle = .fullScreen
                nextVC.hero.isEnabled = true
                nextVC.hero.modalAnimationType = .selectBy(presenting: .fade,
                                                           dismissing: .fade)
                viewController.present(nextVC, animated: true, completion: nil)
                
            } else {
                // (2) 유저가 이미 등록되어 있고, 앱 사용방법 설명이 필요한 경우
                guard let nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController") as? OnboardingViewController else { return }
                nextVC.modalPresentationStyle = .fullScreen
                nextVC.hero.isEnabled = true
                nextVC.hero.modalAnimationType = .selectBy(presenting: .fade,
                                                           dismissing: .fade)
                viewController.present(nextVC, animated: true, completion: nil)
            }
            
        } else {
            // (3) 유저가 등록되어있지 않은 경우
            guard let nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "NicknameViewController") as? NicknameViewController else { return }
            nextVC.modalPresentationStyle = .fullScreen
            nextVC.hero.isEnabled = true
            nextVC.hero.modalAnimationType = .selectBy(presenting: .fade,
                                                       dismissing: .fade)
            viewController.present(nextVC, animated: true, completion: nil)
            UserDefaults.standard.setValue(false, forKey: K.UserDefaults.hideOnboarding)
        }

    }

}

