//
//  SplashViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/06.
//

import UIKit

final class SplashViewModel {
    
    //MARK: - 생성자 관련
    
    init() {
        
    }
    
    //MARK: - 화면 이동 관련
    
    // 다음 화면으로 이동
    func goToNextViewController(viewController: UIViewController) {
        let isUserAlreadyLoggedIn = UserDefaults.standard.bool(forKey: "isUserAlreadyLoggedIn")
        let isOnboardingHidden = UserDefaults.standard.bool(forKey: "hideOnboardingScreen")
        var nextVC: UIViewController = UIViewController()
        
        print("isUserAlreadyLoggedIn: \(isUserAlreadyLoggedIn)")
        print("isOnboardingHidden: \(isOnboardingHidden)")
        
        if isUserAlreadyLoggedIn {
            if isOnboardingHidden {
                nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController ?? UIViewController()
            } else {
                nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController") as? OnboardingViewController ?? UIViewController()
            }
        } else {
            nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController ?? UIViewController()
        }
        
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.hero.isEnabled = true
        nextVC.hero.modalAnimationType = .selectBy(presenting: .zoom,
                                                   dismissing: .zoomOut)
        viewController.present(nextVC, animated: true, completion: nil)
    }
    
}
