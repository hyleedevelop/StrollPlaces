//
//  LoginViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/04.
//

import UIKit
import CryptoKit
import SkyFloatingLabelTextField
import AuthenticationServices
import FirebaseAuth

final class LoginViewModel {

    //MARK: - 속성 관련
    
    private let userDefaults = UserDefaults.standard
    var currentNonce: String?
    
    //MARK: - 생성자 관련
    
    init() {
        
    }

    //MARK: - 사용자 계정 정보 관련
    
    func setUserInfo(nickname: String) {
        self.userDefaults.setValue(nickname, forKey: "userNickname")
    }
    
    //MARK: - 애플 로그인 관련
    
    var appleIDRequest: ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        let nonce = CryptoService.shared.randomNonceString()
        
        request.requestedScopes = [.fullName, .email]
        request.nonce = CryptoService.shared.sha256(nonce)
        self.currentNonce = nonce
        
        return request
    }
    
    /*
    func decode(jwtToken jwt: String) -> [String: Any] {
        let segments = jwt.components(separatedBy: ".")
        return decodeJWTPart(segments[1]) ?? [:]
    }
    
    private func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
              let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
            return nil
        }
        
        return payload
    }
    
    private func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 = base64 + padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
     */
    
    //MARK: - Firebase 관련
    
    func requestFirebaseAuthorization(credential: ASAuthorizationAppleIDCredential) {
        // 1. 현재 nonce가 설정되어 있는지 확인
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        
        // 2. ID 토큰 검색
        guard let appleIDtoken = credential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        
        // 3. 토큰을 문자열로 변환
        guard let idTokenString = String(data: appleIDtoken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDtoken.debugDescription)")
            return
        }
        
        // 4. OAuthProvider에게 방금 로그인한 사용자를 나타내는 credential을 생성하도록 요청
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce
        )
        
        // 5. credential을 이용해 Firebase에 로그인 요청
        FirebaseAuth.Auth.auth().signIn(with: credential) { (authDataResult, error) in
            // 인증 결과에서 Firebase 사용자를 검색하고 사용자 정보를 표시할 수 있다.
            if let user = authDataResult?.user {
                print("애플 로그인 성공!", user.uid, user.email ?? "-")
            }
            
            if error != nil {
                print(error?.localizedDescription ?? "error" as Any)
                return
            }
        }
    }
    
    //MARK: - 화면 이동 관련
    
    // 다음 화면으로 이동
    func goToNextViewController(viewController: UIViewController) {
        guard let nextVC = viewController.storyboard?.instantiateViewController(withIdentifier: "NicknameViewController") as? NicknameViewController else { return }
        
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.hero.isEnabled = true
        nextVC.hero.modalAnimationType = .selectBy(presenting: .fade,
                                                   dismissing: .fade)
        viewController.present(nextVC, animated: true, completion: nil)
    }
    
    //MARK: - Action 관련
    
    func showAlertMessage(success authenticationIsSuccessful: Bool) {
        if authenticationIsSuccessful {
            SPIndicatorService.shared.showSuccessIndicator(title: "로그인 성공")
        } else {
            SPIndicatorService.shared.showErrorIndicator(title: "로그인 실패", message: "인증 불가")
        }
    }

}

