//
//  UINavigationController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/01.
//

import UIKit

extension UINavigationController {
    
    func applyCommonSettings() {
        let navigationBarAppearance = UINavigationBarAppearance()
        //navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundColor = UIColor.white
        
        self.navigationBar.tintColor = K.Color.mainColor
        self.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        self.navigationBar.prefersLargeTitles = false
        self.navigationBar.isTranslucent = true
        self.navigationBar.isHidden = false
        self.additionalSafeAreaInsets.top = 10
        
//        self.setNeedsStatusBarAppearanceUpdate()
    
//        self.extendedLayoutIncludesOpaqueBars = true
    }
    
}

