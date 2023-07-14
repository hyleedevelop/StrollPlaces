//
//  CommonViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/18.
//

import Foundation
import RxSwift
import RxCocoa

class CommonViewModel {
    
    //MARK: - 앱 기본값 설정 관련
    
    // MY 산책길 정렬 기준 선택값
    var selectedContextMenu: Int {
        get { UserDefaults.standard.integer(forKey: K.UserDefaults.selectedContextMenu) }
        set { UserDefaults.standard.setValue(newValue, forKey: K.UserDefaults.selectedContextMenu) }
    }
    
    // 지도 종류
    var mapType: Int {
        get { UserDefaults.standard.integer(forKey: K.UserDefaults.mapType) }
        set { UserDefaults.standard.setValue(newValue, forKey: K.UserDefaults.mapType) }
    }
    
    // 지도 표시 범위
    var mapRadius: Double {
        get { UserDefaults.standard.double(forKey: K.UserDefaults.mapRadius).km }
        set { UserDefaults.standard.setValue(newValue, forKey: K.UserDefaults.mapRadius) }
    }
    
    // MY산책길 존재 여부
    var isMyPlaceExist: Bool {
        get { UserDefaults.standard.bool(forKey: K.UserDefaults.isMyPlaceExist) }
        set { UserDefaults.standard.setValue(newValue, forKey: K.UserDefaults.isMyPlaceExist) }
    }
    
    // 온보딩 화면 표출 여부
    var shouldOnboardingHidden: Bool {
        get { UserDefaults.standard.bool(forKey: K.UserDefaults.hideOnboarding) }
        set { UserDefaults.standard.setValue(newValue, forKey: K.UserDefaults.hideOnboarding) }
    }
    
    //MARK: - 사용자 계정 상태 관련
    
    // 사용자의 회원가입 여부
    var signUpStatus: Bool {
        get { UserDefaults.standard.bool(forKey: K.UserDefaults.signUpStatus) }
        set { UserDefaults.standard.setValue(newValue, forKey: K.UserDefaults.signUpStatus) }
    }
    
    // 사용자의 로그인 여부
    var signInStatus: Bool {
        get { UserDefaults.standard.bool(forKey: K.UserDefaults.signInStatus) }
        set { UserDefaults.standard.setValue(newValue, forKey: K.UserDefaults.signInStatus) }
    }
    
    // 사용자의 이메일
    var userEmail: String? {
        get { UserDefaults.standard.string(forKey: K.UserDefaults.userEmail) }
        set { UserDefaults.standard.setValue(newValue, forKey: K.UserDefaults.userEmail) }
    }
    
    // 사용자의 회원가입 및 로그인 여부 업데이트
//    func updateAccountStatus(signUp: Bool, signIn: Bool) {
//        self.signUpStatus = signUp
//        self.signInStatus = signIn
//    }
    
    //MARK: - 온보딩 관련
    
    // 온보딩 스크린 표출 여부
    //let shouldOnboardingHidden = BehaviorSubject<Bool>(value: false)
    
    
}
