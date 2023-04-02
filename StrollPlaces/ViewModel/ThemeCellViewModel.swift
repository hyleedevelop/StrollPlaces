//
//  ThemeCollectionViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import RxSwift

final class ThemeCellViewModel {
    
    //MARK: - property
    
    let themeCellData: ThemeCellData
    
    var icon: Observable<UIImage> {
        return Observable<UIImage>.just(themeCellData.icon)
    }

    var title: Observable<String> {
        return Observable<String>.just(themeCellData.title)
    }
    
    //MARK: - initializer
    
    init(_ themeCellData: ThemeCellData) {
        self.themeCellData = themeCellData
    }
    
}
