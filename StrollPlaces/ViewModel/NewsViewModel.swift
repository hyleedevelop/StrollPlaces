//
//  NewsViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/24.
//

import Foundation
import RxSwift
import RxCocoa

//MARK: - NewsList View Model

// 테이블뷰 컨트롤러에 대한 뷰모델 (Root View Model)
// 추후 메인화면에 다른 UI 요소가 추가될 수도 있기 때문에 확장성 측면에서 뉴스 아이템에 대한 뷰모델을 따로 분리하였음 (for flexibility)
final class NewsListViewModel {
    
    let newsViewModel: [NewsViewModel]
    
    init(_ newsViewModel: [News]) {
        self.newsViewModel = newsViewModel.compactMap(NewsViewModel.init)
    }
    
    func articleAt(_ index: Int) -> NewsViewModel {
        return self.newsViewModel[index]
    }
    
}

//MARK: - News View Model

// 뉴스 아이템(셀) 하나하나에 대한 뷰모델
final class NewsViewModel {
    
    let news: News
    
    init(_ news: News) {
        self.news = news
    }
    
    var title: Observable<String> {
        return Observable<String>.just(news.title)
    }
    
    var description: Observable<String> {
        return Observable<String>.just(news.description ?? "")
    }
    
}
