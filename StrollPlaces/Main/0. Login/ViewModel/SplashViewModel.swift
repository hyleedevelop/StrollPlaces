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
        guard let nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
        
//        let isUserAlreadyLoggedIn = UserDefaults.standard.bool(forKey: K.UserDefaults.loginStatus)
//        let isOnboardingHidden = UserDefaults.standard.bool(forKey: K.UserDefaults.hideOnboarding)
//        var nextVC: UIViewController = UIViewController()
//
//        print("User is already logged in: \(isUserAlreadyLoggedIn)")
//        print("Onboarding should be hidden: \(isOnboardingHidden)")
//
//        if isUserAlreadyLoggedIn {
//            if isOnboardingHidden {
//                nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "UITabBarController") as? UITabBarController ?? UIViewController()
//            } else {
//                nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController") as? OnboardingViewController ?? UIViewController()
//            }
//        } else {
//            nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController ?? UIViewController()
//        }
        
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.hero.isEnabled = true
        nextVC.hero.modalAnimationType = .selectBy(presenting: .zoom,
                                                   dismissing: .zoomOut)
        viewController.present(nextVC, animated: true, completion: nil)
    }
    
}
