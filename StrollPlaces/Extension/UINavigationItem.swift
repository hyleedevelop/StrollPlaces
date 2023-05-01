//
//  UINavigationItem.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/01.
//

import UIKit
import SnapKit

extension UINavigationItem {
 
    func makeLeftSideTitle(title: String) {
        // 커스텀 타이틀 지정
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.black
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        self.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
    }
    
    func makeSFSymbolButton(_ target: Any?, action: Selector, symbolName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: symbolName), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.tintColor = UIColor.black
        
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.customView?.snp.makeConstraints {
            $0.height.width.equalTo(24)
        }
        
        return barButtonItem
    }
    
    func makeSFSymbolButton(_ target: Any?, menu: UIMenu, symbolName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: symbolName), for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.menu = menu
        button.tintColor = UIColor.black
        
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.customView?.snp.makeConstraints {
            $0.height.width.equalTo(24)
        }
        
        return barButtonItem
    }
    
}
