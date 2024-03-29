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
        label.heroID = "mainTitle"
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "나만을 위한 산책 앱"
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.heroID = "subTitle"
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
    
    private let viewModel = SplashViewModel()
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        self.setupLabel()
        self.setupAnimationView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-150)
            $0.height.equalTo(30)
        }
        
        // "나만을 위한 산책 앱"
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
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(150)
            $0.bottom.equalTo(self.subtitleLabel.snp.top).offset(-50)
        }
        
        // 애니메이션 재생
        self.initialAnimationView.play()
    }
    
    // 일정 시간 경과 후 다음 화면으로 이동
    private func goToNextViewController() {
        DispatchQueue.main.asyncAfter(deadline: .now() + K.App.splashScreenTime) {
            self.viewModel.goToNextViewController(
                viewController: self,
                skipOnboarding: self.viewModel.shouldOnboardingHidden
            )
        }
    }

}
