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
    
    func decode(jwtToken jwt: String) -> [String: Any] {
        let segments = jwt.components(separatedBy: ".")
        return decodeJWTPart(segments[1]) ?? [:]
    }
    
    private func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
              let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
              let payload = json as? [String: Any] else {
            return nil
        }
        
        return payload
    }
    
    private func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 = base64 + padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
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
        
        if !isUserAlreadySignedUp {
            // 유저가 등록되어있지 않은 경우
            guard let nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "NicknameViewController") as? NicknameViewController else { return }
            nextVC.modalPresentationStyle = .fullScreen
            nextVC.hero.isEnabled = true
            nextVC.hero.modalAnimationType = .selectBy(presenting: .fade,
                                                       dismissing: .fade)
            viewController.present(nextVC, animated: true, completion: nil)
            UserDefaults.standard.setValue(false, forKey: K.UserDefaults.hideOnboarding)
        } else {
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
            }
        }

    }

}

