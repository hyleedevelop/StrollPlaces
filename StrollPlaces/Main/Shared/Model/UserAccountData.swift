//
//  UserAccountData.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/05.
//

import Foundation

final class UserAccountData {
    
    static let shared = UserAccountData()
    private init() {}
    
    var nickname: String = ""
    
}
