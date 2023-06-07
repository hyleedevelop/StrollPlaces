//
//  CryptoService.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/06.
//

import UIKit
import CryptoKit
import SwiftJWT
import Alamofire

final class CryptoService {
    
    static let shared = CryptoService()
    private init() {}
    
    // 랜덤 Nonce 문자열 생성
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // 해시 문자열 가져오기
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // JWT 문자열 생성
    func createJWT() -> String {
        let myHeader = Header(kid: K.Login.appleKeyID)
        struct MyClaims: Claims {
            let iss: String
            let iat: Int
            let exp: Int
            let aud: String
            let sub: String
        }
        
        let nowDate = Date()
        var dateComponent = DateComponents()
        dateComponent.month = 6
        let iat = Int(Date().timeIntervalSince1970)
        let exp = iat + 3600
        let myClaims = MyClaims(iss: K.App.appTeamID,
                                iat: iat,
                                exp: exp,
                                aud: "https://appleid.apple.com",
                                sub: K.App.appBundleID)
        
        var myJWT = JWT(header: myHeader, claims: myClaims)
        
        // JWT 발급을 요청값의 암호화 과정에서 다운받아두었던 Key File이 필요하다.(.p8 파일)
        guard let url = Bundle.main.url(forResource: K.Login.keyFileName, withExtension: "p8") else{
            return ""
        }
        let privateKey: Data = try! Data(contentsOf: url, options: .alwaysMapped)
        
        let jwtSigner = JWTSigner.es256(privateKey: privateKey)
        let signedJWT = try! myJWT.sign(using: jwtSigner)
        
        UserDefaults.standard.set(signedJWT, forKey: "AppleClientSecret")
        
        print("🗝 singedJWT - \(signedJWT)")
        return signedJWT
    }

}
