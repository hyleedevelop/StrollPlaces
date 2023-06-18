//
//  NicknameViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/05.
//

import UIKit
import SkyFloatingLabelTextField
import FirebaseAuth
import FirebaseFirestore
import RxSwift

final class NicknameViewModel {
    
    //MARK: - in 속성 관련
    
    
    //MARK: - out 속성 관련
    
    var isUserRegistered = BehaviorSubject<Bool>(value: false)
    
    //MARK: - 내부 속성 관련
    
    
    
    //MARK: - 생성자 관련
    
    init() {
        
    }
    
    //MARK: - 입력값에 대한 유효성 검사 관련
    
    // TextField에 입력된 문자열에 대한 유효성 검사
    func checkTextFieldIsValid(text: String, textField: SkyFloatingLabelTextField, isNameField: Bool) -> Observable<Bool> {
        let isEnabled = InputValidationService.shared.validateInputText(text: text, textField: textField, isNameField: isNameField)
        return Observable<Bool>.just(isEnabled)
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
    
    //MARK: - Firebase DB 관련
    
    func createUserData(nickname: String) {
//        guard let uid = Auth.auth().currentUser?.uid,
//              let email = Auth.auth().currentUser?.email else { return }
        guard let userEmail = UserDefaults.standard.string(forKey: K.UserDefaults.userEmail) else { return }
        
        Firestore
            .firestore()
            .collection(K.Authorization.collectionName)
            .document(userEmail)
            .setData([
                //K.Login.uidField: uid,
                K.Authorization.emailField: userEmail,
                K.Authorization.nicknameField: nickname,
                K.Authorization.signupDateField: Timestamp(date: Date())
            ]) { error in
                if let errorMessage = error {
                    print("There was an issue saving data to firestore, \(errorMessage)")
                } else {
                    self.isUserRegistered.onNext(true)
                    UserDefaults.standard.setValue(true, forKey: K.UserDefaults.signupStatus)
                    UserDefaults.standard.setValue(true, forKey: K.UserDefaults.loginStatus)
                }
            }
            
    }
}
