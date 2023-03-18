//
//  ThemeCollectionViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import RxSwift

final class ThemeCellViewModel {
    
    let themeCellData: ThemeCellData
    //let icon: UIImage
    //let title: String
    
    var icon: Observable<UIImage> {
        return Observable<UIImage>.just(themeCellData.icon)
    }

    var title: Observable<String> {
        return Observable<String>.just(themeCellData.title)
    }
    
    init(_ themeCellData: ThemeCellData) {
        self.themeCellData = themeCellData
        //self.icon = themeCell.icon
        //self.title = themeCell.title
    }
    
}
