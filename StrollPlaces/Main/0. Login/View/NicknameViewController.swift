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

    private func setupTextField() {
        self.nicknameField.rx.text.orEmpty
            .skip(1)
            .asSignal(onErrorJustReturn: "")
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                let str = self.viewModel.limitTextFieldLength(
                    text: $0, textField: self.nicknameField, isNameField: true
                )
                let isValid = self.viewModel.checkTextFieldIsValid(
                    text: str, textField: self.nicknameField, isNameField: true
                )
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func setupButton() {
        self.saveButton.rx.tap
            .subscribe(onNext: {
                self.registerUserToFirebase()
                self.viewModel.goToNextViewController(viewController: self)
            })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - indirectly called method
    
    private func registerUserToFirebase() {
        // 📍 Firebase DB에 사용자가 입력한 닉네임과 UID를 함께 저장하도록 구현
    }

}
