//
//  MoreViewController+AppleLogin.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/07.
//

import UIKit
import Alamofire
import AuthenticationServices

extension MoreViewController {
    
    internal func makeRevokeEvent() {
        let jwtString = CryptoService.shared.createJWT()
        
        guard let authCode = UserDefaults.standard.string(forKey: "theAuthorizationCode") else { return }
        
        self.getAppleRefreshToken(code: authCode) { output in
            let clientSecret = jwtString
            
            if let refreshToken = output.refresh_token {
                print("Client_Secret - \(clientSecret)")
                print("Refresh_Token - \(refreshToken)")
                
                // Apple API 통신
                self.revokeAppleToken(clientSecret: clientSecret, token: refreshToken) {
                    print("Apple revoke token Success")
                    self.performSegue(
                        withIdentifier: "ToSplashViewController", sender: self
                    )
                    self.viewModel.requestFirebaseRevoke(viewController: self)
                }
            } else{
                SPIndicatorService.shared.showErrorIndicator(title: "회원탈퇴 실패", message: "회원탈퇴를 진행 불가")
            }
            
        }
    }
    
    // 1. Apple Refresh Token 받기
    private func getAppleRefreshToken(code: String, completion: @escaping (AppleTokenResponse) -> Void) {
        guard let secret = UserDefaults.standard.string(forKey: "AppleClientSecret") else { return }
        
        let url = "https://appleid.apple.com/auth/token?client_id=\(K.App.appBundleID)&client_secret=\(secret)&code=\(code)&grant_type=authorization_code"
        let header: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        
        print("🗝 clientSecret - \(UserDefaults.standard.string(forKey: "AppleClientSecret") ?? "값없음")")
        print("🗝 authCode - \(code)")
        
        AF.request(url,
                   method: .post,
                   encoding: JSONEncoding.default,
                   headers: header)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                    
                case .success(let output):
                    if let decodedData = try? JSONDecoder().decode(AppleTokenResponse.self, from: output) {
                        
                        if decodedData.refresh_token == nil{
                            SPIndicatorService.shared.showErrorIndicator(title: "탈퇴 실패", message: "검증되지 않은 토큰")
                        } else {
                            completion(decodedData)
                        }
                    }
                        
                case .failure(_):
                    print("애플 토큰 발급 실패 - \(response.error.debugDescription)")
                }
            }
    }
    
    // 2. Apple Token 폐지
    internal func revokeAppleToken(clientSecret: String, token: String, completion: @escaping () -> Void) {
        
        let url = "https://appleid.apple.com/auth/revoke?client_id=\(K.App.appBundleID)&client_secret=\(clientSecret)&token=\(token)&token_type_hint=refresh_token"
        let header: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        
        AF.request(url,
                   method: .post,
                   headers: header)
        .validate(statusCode: 200..<600)
        .responseData { response in
            guard let statusCode = response.response?.statusCode else { return }
            if statusCode == 200 {
                print("애플 토큰 삭제 성공!")
                completion()
            }
        }
    }
    
}

