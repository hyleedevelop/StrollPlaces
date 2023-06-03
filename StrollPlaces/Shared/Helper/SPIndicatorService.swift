//
//  SPIndicatorService.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/29.
//

import Foundation
import SPIndicator

final class SPIndicatorService {
    
    static let shared = SPIndicatorService()
    private init() {}
    
    func showSuccessIndicator(
        title: String,
        type: SPIndicatorIconPreset = .done,
        haptic: SPIndicatorHaptic = .success,
        duration: TimeInterval = 1.0
    ) {
        SPIndicatorView(title: title, preset: type)
            .present(duration: duration, haptic: haptic)
    }
    
    func showErrorIndicator(
        title: String,
        message: String,
        type: SPIndicatorIconPreset = .error,
        haptic: SPIndicatorHaptic = .error,
        duration: TimeInterval = 2.0
    ) {
        SPIndicatorView(title: title, message: message, preset: type)
            .present(duration: duration, haptic: haptic)
    }
    
}
