//
//  ViewModelBindableType.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/18.
//

import UIKit

protocol ViewModelBindableType {
    
    // 뷰컨트롤러마다 뷰모델의 타입이 달라질 것이므로 연관값을 이용해 제네릭 프로토콜을 사용
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    func setupBinding()
    
}

// 이 프로토콜을 채택하는 뷰컨트롤러의 경우
extension ViewModelBindableType where Self: UIViewController {
    
    // 이렇게 작성하면 뷰컨트롤러에서 bindViewModel() 메서드를 직접 호출할 필요가 없어짐
    mutating func bind(viewModel: Self.ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        
        self.setupBinding()
    }
    
}
