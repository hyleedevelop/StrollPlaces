//
//  FeedViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/04.
//

import UIKit

final class FeedViewModel {
    
    //MARK: - 생성자
    
    init() {
        
    }
    
    //MARK: - TableView 관련
    
    // section의 개수
    let numberOfSections: Int = 1
    
    // section당 row의 개수
    func numberOfRowsInSection(at section: Int) -> Int {
        return 5
    }
    
}
