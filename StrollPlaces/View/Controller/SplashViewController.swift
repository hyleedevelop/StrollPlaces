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

    //MARK: - IB outlet & action

    //MARK: - UI property
    
    private lazy var initialAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "walkingMan")
        //view.frame = self.view.bounds
        //view.center = self.view.center
        view.contentMode = .scaleAspectFit
        view.loopMode = .repeat(2)
        view.animationSpeed = 0.75
        view.alpha = 1
        //view.play()
        return view
    }()
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true
        
        self.setupSplashScreen()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true)
            //self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //MARK: - directly called method
    
    private func setupSplashScreen() {
        self.view.addSubview(initialAnimationView)
        
        self.initialAnimationView.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(300)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-200)
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

}
