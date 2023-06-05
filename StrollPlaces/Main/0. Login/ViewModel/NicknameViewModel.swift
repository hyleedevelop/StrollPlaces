//
//  NicknameViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/05.
//

import UIKit
import SkyFloatingLabelTextField

final class NicknameViewModel {
    
    //MARK: - 생성자 관련
    
    init() {
        
    }
    
    //MARK: - 입력값에 대한 유효성 검사 관련
    
    // TextField에 입력된 문자열에 대한 유효성 검사
    func checkTextFieldIsValid(text: String, textField: SkyFloatingLabelTextField, isNameField: Bool) -> Bool {
        return InputValidationService.shared.validateInputText(text: text, textField: textField, isNameField: isNameField)
    }
    
    // TextField의 글자수 제한을 넘기면 초과되는 부분은 입력되지 않도록 설정
    func limitTextFieldLength(text: String, textField: UITextField, isNameField: Bool) -> String {
        return InputValidationService.shared.limitInputText(text: text, textField: textField, isNameField: isNameField)
    }
    
    //MARK: - 화면 이동 관련
    
    // 다음 화면으로 이동
    func goToNextViewController(viewController: UIViewController) {
        guard let nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController")
                as? OnboardingViewController else { return }
        
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.hero.isEnabled = true
        nextVC.hero.modalAnimationType = .selectBy(presenting: .zoom,
                                                   dismissing: .zoomOut)
        viewController.present(nextVC, animated: true, completion: nil)
    }
    
}
