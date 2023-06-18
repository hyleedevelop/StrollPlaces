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
    
    let isUserAlreadySignedUp = BehaviorSubject<Bool>(value: false)
    let isUserAlreadyLoggedIn = BehaviorSubject<Bool>(value: false)
    let hideOnboarding = BehaviorSubject<Bool>(value: false)
    
//    init(...) {
//}
    
}
