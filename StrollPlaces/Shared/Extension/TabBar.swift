//
//  TabBar.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/09.
//

import UIKit

//MARK: - UITabBar

extension UITabBar {
    
    // 커스텀 탭바 적용
    static func clearShadow() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
}

//MARK: - CALayer

extension CALayer {
    
    // Sketch 스타일의 그림자를 생성하는 유틸리티 함수
    func applyShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4
    ) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
    }
    
}
