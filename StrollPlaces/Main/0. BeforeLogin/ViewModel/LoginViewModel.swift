//
//  LoginViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/04.
//

import UIKit
import SkyFloatingLabelTextField

final class LoginViewModel {
    
    //MARK: - 생성자 관련
    
    init() {
        
    }
    
    //MARK: - 속성 관련
    
    private let userDefaults = UserDefaults.standard

    //MARK: - 소셜 로그인 관련
    
    func requestAuthentication(with type: LoginType, completion: ((Bool) -> Void)?) {
        print(#function)
        // 📍 인증에 성공했다면...
        completion?(true)
        
        // 📍 인증에 실패했다면...
        //completion(false)
    }
    
    //MARK: - 화면 이동 관련
    
    // 다음 화면으로 이동
    func goToNextViewController(viewController: UIViewController) {
        // ✅ for debugging...
        // --------------------------------------------------------------
        //self.userDefaults.setValue(false, forKey: "hideOnboardingScreen")
        // --------------------------------------------------------------
        
        
        let onboardingScreenShouldBeHidden = self.userDefaults.bool(forKey: "hideOnboardingScreen")
        
        if onboardingScreenShouldBeHidden {
            guard let nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "TabBar")
                    as? UITabBarController else { return }
            
            nextVC.modalPresentationStyle = .fullScreen
            nextVC.hero.isEnabled = true
            nextVC.hero.modalAnimationType = .selectBy(presenting: .zoom,
                                                       dismissing: .zoomOut)
            viewController.present(nextVC, animated: true, completion: nil)
        } else {
            guard let nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController")
                    as? OnboardingViewController else { return }
            
            nextVC.modalPresentationStyle = .fullScreen
            nextVC.hero.isEnabled = true
            nextVC.hero.modalAnimationType = .selectBy(presenting: .slide(direction: .down),
                                                       dismissing: .slide(direction: .down))
            viewController.present(nextVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - Action 관련
    func showAlertMessage(success authenticationIsSuccessful: Bool) {
        if authenticationIsSuccessful {
            SPIndicatorService.shared.showSuccessIndicator(title: "로그인 성공")
        } else {
            SPIndicatorService.shared.showErrorIndicator(title: "로그인 실패", message: "인증 불가")
        }
    }

}

