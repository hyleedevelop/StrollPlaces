//
//  TextValidationService.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/03.
//

import UIKit
import SkyFloatingLabelTextField

final class InputValidationService {
    
    static let shared = InputValidationService()
    private init() {}
 
    // SkyFloatingTextField에 입력된 문자열에 대한 유효성 검사
    func validateInputText(text: String, textField: SkyFloatingLabelTextField, isNameField: Bool) -> Bool {
        if isNameField {
            // 문자열 길이가 적절한지 판단
            let isLengthValid: Bool = (2...10) ~= text.count
            // 문자열이 기존의 Realm DB에 저장된 산책길 이름과 중복되지 않는지 판단
            let isUniqueName: Bool = self.checkIfThereIsTheSameName(name: text)
            
            // 텍스트필드 아래에 에러 메세지 표출
            if !isLengthValid {
                textField.errorMessage = "2글자 이상, 10글자 이하"
            } else {
                textField.errorMessage = !isUniqueName ? "중복되는 이름" : nil
            }
            
            return isLengthValid && isUniqueName
        } else {
            // 문자열 길이가 적절한지 판단
            let isLengthValid: Bool = (2...20) ~= text.count
            
            // 텍스트필드 아래에 에러 메세지 표출
            textField.errorMessage = !isLengthValid ? "2글자 이상, 20글자 이하" : nil
            
            return isLengthValid
        }
    }
    
    // 로그인 화면에서 입력된 이메일 문자열에 대한 유효성 검사
    func validateInputEmailText(text: String) -> Bool {
        // 📍 문자열에 @와 .가 반드시 포함되어있는지 확인하는 코드 작성하기

        return true
    }
    
    // TextField에 입력된 문자열에 대한 길이 검사
    func validateLength(text: String, textField: UITextField, isNameField: Bool) -> Bool {
        if isNameField {
            // 문자열 길이가 적절한지 판단
            let isLengthValid: Bool = (2...10) ~= text.count
            // 문자열이 기존의 Realm DB에 저장된 산책길 이름과 중복되지 않는지 판단
            let isUniqueName: Bool = self.checkIfThereIsTheSameName(name: text)
            
            return isLengthValid && isUniqueName
        } else {
            // 문자열 길이가 적절한지 판단
            let isLengthValid: Bool = (2...20) ~= text.count
            
            return isLengthValid
        }
    }
    
    // TextField에 입력된 문자열에 대한 중복 검사
    func validateUniqueName(text: String, textField: UITextField, isNameField: Bool) -> Bool {
        return self.checkIfThereIsTheSameName(name: text)
    }
    
    // TextField의 글자수 제한을 넘기면 초과되는 부분은 입력되지 않도록 설정
    func limitInputText(text: String, textField: UITextField, isNameField: Bool) -> String {
        let maxLength: Int = isNameField ? 10 : 20
        if text.count > maxLength {
            let index = text.index(text.startIndex, offsetBy: maxLength)
            textField.text = String(text[..<index])
            return String(text[..<index])
        } else {
            return text
        }
    }
    
    // 산책길 난이도 별점에 대한 유효성 검사
    func checkStarRatingIsValid(value: Double) -> Bool {
        return (1.0...5.0) ~= value ? true : false
    }
    
    // 입력한 산책길 이름이 Realm DB에 저장된 산책길 이름과 중복되는지 체크
    private func checkIfThereIsTheSameName(name: String) -> Bool {
        let trackData = RealmService.shared.realm.objects(TrackData.self)
        return trackData.firstIndex(where: { $0.name == name } ) == nil ? true : false
    }
    
}
