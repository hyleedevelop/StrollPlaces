//
//  UINavigationController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/01.
//

import UIKit

extension UINavigationController {
    
    func applyCommonSettings() {
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.shadowColor = UIColor.systemGray5
        standardAppearance.backgroundColor = UIColor.white
        
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.shadowColor = UIColor.clear
        scrollEdgeAppearance.backgroundColor = UIColor.white
        
        self.navigationBar.standardAppearance = standardAppearance
        self.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
        self.navigationBar.prefersLargeTitles = false
        self.navigationBar.isTranslucent = true
        self.navigationBar.isHidden = false
        self.navigationBar.backgroundColor = UIColor.white
        self.additionalSafeAreaInsets.top = 10
        
        self.setNeedsStatusBarAppearanceUpdate()
        //self.extendedLayoutIncludesOpaqueBars = true
    }
    
}

