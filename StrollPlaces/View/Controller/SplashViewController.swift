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
        label.text = "가벼운 발걸음"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }()
    
    private lazy var initialAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "walkingMan")
        //view.frame = self.view.bounds
        //view.center = self.view.center
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.animationSpeed = 0.75
        view.alpha = 1
        //view.play()
        return view
    }()
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        self.setupAnimationView()
        self.setupLabel()
        self.goToNextViewController()
    }
    
    //MARK: - directly called method
    
    // View 설정
    private func setupView() {
        self.view.backgroundColor = K.Color.themeGreen
    }
    
    // Lottie Animation 설정
    private func setupAnimationView() {
        self.view.addSubview(self.initialAnimationView)
        self.initialAnimationView.snp.makeConstraints {
            $0.left.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            $0.right.equalTo(self.view.safeAreaLayoutGuide).offset(-50)
            $0.top.equalTo(self.view.snp.centerY).offset(-50)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-100)
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
    
    // Label 설정
    private func setupLabel() {
        self.view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.left.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            $0.right.equalTo(self.view.safeAreaLayoutGuide).offset(-50)
            $0.bottom.equalTo(self.initialAnimationView.snp.top).offset(-80)
        }
    }
    
    // 다음 화면으로 이동
    private func goToNextViewController() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController")
                    as? OnboardingViewController else { return }
            
            nextVC.modalPresentationStyle = .fullScreen
            nextVC.hero.isEnabled = true
            nextVC.hero.modalAnimationType = .selectBy(presenting: .zoomSlide(direction: .left), dismissing: .zoomSlide(direction: .left))
            
            self.present(nextVC, animated: true, completion: nil)
        }
    }

}
