//
//  NicknameViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/05.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SkyFloatingLabelTextField

class NicknameViewController: UIViewController {

    //MARK: - IB outlet
    
    @IBOutlet weak var nicknameField: SkyFloatingLabelTextField!
    @IBOutlet weak var saveButton: UIButton!
    
    //MARK: - property
    
    private let viewModel = NicknameViewModel()
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTextField()
        self.setupButton()
    }
    
    //MARK: - directly called method

    // TextField 설정
    private func setupTextField() {
        // 닉네임을 조건에 맞게 입력 시 저장 버튼 활성화
        self.nicknameField.rx.text.orEmpty
            .skip(1)
            .flatMap { text in
                return self.viewModel.checkTextFieldIsValid(
                    text: text, textField: self.nicknameField, isNameField: true
                )
            }
            .bind(onNext: { isEnabled in
                self.saveButton.isEnabled = isEnabled
            })
            .disposed(by: rx.disposeBag)
    }
    
    // Button 설정
    private func setupButton() {
        self.saveButton.layer.cornerRadius = 5
        self.saveButton.clipsToBounds = true
        
        // 저장 버튼 클릭 시
        self.saveButton.rx.tap
            .asObservable()
            .subscribe(onNext: {
                self.viewModel.createUserData(nickname: self.nicknameField.text ?? "닉네임없음")
            })
            .disposed(by: rx.disposeBag)
        
        // 사용자 등록 처리가 성공적으로 종료된 경우 다음 화면으로 이동
        self.viewModel.isUserRegistered
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] allowed in
                guard let self = self else { return }
                self.viewModel.goToNextViewController(viewController: self)
            })
            .disposed(by: rx.disposeBag)
    }

}
