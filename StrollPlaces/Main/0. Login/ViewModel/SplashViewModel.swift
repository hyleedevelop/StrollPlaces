//
//  SplashViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/06.
//

import UIKit
import RealmSwift

final class SplashViewModel: CommonViewModel {
    
    //MARK: - 생성자 관련
    
    override init() {
        
    }
    
    //MARK: - 화면 이동 관련
    
    // 다음 화면으로 이동
    func goToNextViewController(viewController: UIViewController, skipOnboarding: Bool) {
        //guard let nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
        
        if skipOnboarding {
            guard let nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "UITabBarController") as? UITabBarController else { return }
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
            nextVC.hero.modalAnimationType = .selectBy(presenting: .zoom,
                                                       dismissing: .zoomOut)
            viewController.present(nextVC, animated: true, completion: nil)
        }
    }
    
}
