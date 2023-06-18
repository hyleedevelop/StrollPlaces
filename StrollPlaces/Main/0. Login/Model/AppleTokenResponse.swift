//
//  AppleTokenResponse.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/07.
//

import Foundation

// 애플 엑세스 토큰 발급 응답 모델
struct AppleTokenResponse: Codable {
    
    //var access_token: String?
    //var token_type: String?
    //var expires_in: Int?
    var refresh_token: String?  // ⭐️ 회원탈퇴 진행 시 필요한 토큰
    //var id_token: String?

    enum CodingKeys: String, CodingKey {
        case refresh_token = "refresh_token"
    }
    
}
