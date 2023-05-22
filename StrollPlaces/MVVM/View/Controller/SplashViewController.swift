//
//  LoginViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/19.
//

import UIKit
import SnapKit
import Lottie

final class SplashViewController: UIViewController {

    //MARK: - UI property
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = K.App.appName
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "나를 위한 산책 앱"
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }()
    
    private lazy var initialAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "walkingMan")
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.animationSpeed = 0.85
        view.alpha = 1
        return view
    }()
    
    //MARK: - normal property
    
    private let userDefaults = UserDefaults.standard
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        self.setupLabel()
        self.setupAnimationView()
        self.goToNextViewController()
    }
    
    //MARK: - directly called method
    
    // View 설정
    private func setupView() {
        self.view.setVerticalGradient(color1: K.Color.themeSky, color2: K.Color.themeGreen)
    }
    
    // Label 설정
    private func setupLabel() {
        // "가벼운 발걸음"
        self.view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.left.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            $0.right.equalTo(self.view.safeAreaLayoutGuide).offset(-50)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-150)  //
            $0.height.equalTo(30)
        }
        
        // "오늘 하루가 행복해지는"
        self.view.addSubview(self.subtitleLabel)
        self.subtitleLabel.snp.makeConstraints {
            $0.left.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            $0.right.equalTo(self.view.safeAreaLayoutGuide).offset(-50)
            $0.bottom.equalTo(self.titleLabel.snp.top).offset(-10)
            $0.height.equalTo(17)
        }
    }
    
    // Lottie Animation 설정
    private func setupAnimationView() {
        self.view.addSubview(self.initialAnimationView)
        self.initialAnimationView.snp.makeConstraints {
            $0.left.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            $0.right.equalTo(self.view.safeAreaLayoutGuide).offset(-50)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(150)  //
            $0.bottom.equalTo(self.subtitleLabel.snp.top).offset(-50)
        }
        
        self.initialAnimationView.play { _ in
            UIView.animate(withDuration: 1, animations: {
                self.initialAnimationView.alpha = 0
            }, completion: { _ in
                self.initialAnimationView.isHidden = true
                self.initialAnimationView.removeFromSuperview()
            })
        }
    }
    
    // 다음 화면으로 이동
    private func goToNextViewController() {
        // ✅ for debugging...
        // --------------------------------------------------------------
        //self.userDefaults.setValue(false, forKey: "hideOnboardingScreen")
        // --------------------------------------------------------------
        
        let hideOnboardingScreen = self.userDefaults.bool(forKey: "hideOnboardingScreen")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + K.App.splashScreenTime) {
            if hideOnboardingScreen {
                guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBar")
                        as? UITabBarController else { return }

                nextVC.modalPresentationStyle = .fullScreen
                nextVC.hero.isEnabled = true
                nextVC.hero.modalAnimationType = .selectBy(presenting: .zoom,
                                                           dismissing: .zoomOut)
                self.present(nextVC, animated: true, completion: nil)
            } else {
                guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController")
                        as? OnboardingViewController else { return }

                nextVC.modalPresentationStyle = .fullScreen
                nextVC.hero.isEnabled = true
                nextVC.hero.modalAnimationType = .selectBy(presenting: .slide(direction: .down),
                                                           dismissing: .slide(direction: .down))
                self.present(nextVC, animated: true, completion: nil)
            }
        }
    }

}
