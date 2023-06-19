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

final class LoginViewModel: CommonViewModel {

    //MARK: - 속성 관련
    
    //let isUserAlreadySignedUp = BehaviorSubject<Bool>(value: false)
    let isLoginAllowed = BehaviorSubject<Bool>(value: false)
    
    //MARK: - 생성자 관련
    
    override init() {
        
    }
    
    //MARK: - 화면 이동 관련
    
    // 다음 화면으로 이동
    func goToNextViewController(viewController: UIViewController) {
        let isUserAlreadySignedUp = UserDefaults.standard.bool(forKey: K.UserDefaults.signUpStatus)
        let isUserAlreadyLoggedIn = UserDefaults.standard.bool(forKey: K.UserDefaults.signInStatus)
        let hideOnboarding = UserDefaults.standard.bool(forKey: K.UserDefaults.hideOnboarding)
        
        print("사용자가 이미 회원가입 되어 있습니까?: \(isUserAlreadySignedUp)")
        print("사용자가 이미 로그인 되어 있습니까?: \(isUserAlreadyLoggedIn)")
        print("앱 사용방법 설명이 필요없습니까?: \(hideOnboarding)")
        
        if isUserAlreadySignedUp == false {
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

