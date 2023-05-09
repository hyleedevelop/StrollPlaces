//
//  UIButton.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/09.
//

import UIKit

//MARK: - UIButton

extension UIButton {
    
    // 시작/종료 버튼 UI 변경
    func changeAttributes(buttonTitle: String, interaction: Bool) {
        DispatchQueue.main.async {
            let attributedText = NSAttributedString(
                string: buttonTitle,
                attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold),
                             NSAttributedString.Key.foregroundColor: K.Color.themeWhite]
            )
            self.setAttributedTitle(attributedText, for: .normal)
            self.isUserInteractionEnabled = interaction
        }
    }
    
}
