//
//  LoginViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/04.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class LoginViewController: UIViewController {

    //MARK: - UI property
    
    @IBOutlet weak var naverLoginButton: UIButton!
    @IBOutlet weak var kakaoLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: UIButton!
    
    //MARK: - normal property
    
    private let viewModel = LoginViewModel()
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupButton()
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        self.navigationController?.applyDefaultSettings(hideBar: true)
    }
    
    // 각종 버튼 설정
    private func setupButton() {
        // 버튼의 UI 설정
        [self.naverLoginButton, self.kakaoLoginButton,
         self.googleLoginButton, self.appleLoginButton].forEach {
            $0?.applySocialLoginButtonFormat()
        }
        
        // (1) 네이버 로그인 버튼 클릭 시
        self.naverLoginButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.requestAuthentication(with: .naver) { allowedToLogin in
                    if allowedToLogin {
                        self.viewModel.goToNextViewController(viewController: self)
                        self.viewModel.showAlertMessage(success: true)
                    } else {
                        self.viewModel.showAlertMessage(success: false)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        // (2) 카카오 로그인 버튼 클릭 시
        self.kakaoLoginButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.requestAuthentication(with: .kakao) { allowedToLogin in
                    if allowedToLogin {
                        self.viewModel.goToNextViewController(viewController: self)
                        self.viewModel.showAlertMessage(success: true)
                    } else {
                        self.viewModel.showAlertMessage(success: false)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        // (3) 구글 로그인 버튼 클릭 시
        self.googleLoginButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.requestAuthentication(with: .google) { allowedToLogin in
                    if allowedToLogin {
                        self.viewModel.goToNextViewController(viewController: self)
                        self.viewModel.showAlertMessage(success: true)
                    } else {
                        self.viewModel.showAlertMessage(success: false)
                    }
                }
            })
            .disposed(by: rx.disposeBag)

        // (4) 애플 로그인 버튼 클릭 시
        self.appleLoginButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.requestAuthentication(with: .apple) { allowedToLogin in
                    if allowedToLogin {
                        self.viewModel.goToNextViewController(viewController: self)
                        self.viewModel.showAlertMessage(success: true)
                    } else {
                        self.viewModel.showAlertMessage(success: false)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
    }

}
