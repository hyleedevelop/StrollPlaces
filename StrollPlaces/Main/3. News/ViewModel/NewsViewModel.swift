//
//  NewsViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/24.
//

import Foundation
import RxSwift
import RxCocoa

// 테이블뷰 컨트롤러에 대한 뷰모델 (Root View Model)
// 추후 메인화면에 다른 UI 요소가 추가될 수도 있기 때문에
// 확장성 측면에서 뉴스 아이템에 대한 뷰모델을 따로 분리 (for flexibility)

//MARK: - 뉴스 화면에 대한 뷰모델

final class NewsViewModel: CommonViewModel {
    
    //MARK: - 생성자 관련
    var newsItemViewModel: [NewsItemViewModel]
    
    init(_ newsItemViewModel: [News]) {
        self.newsItemViewModel = newsItemViewModel.compactMap(NewsItemViewModel.init)
    }
    
    //MARK: - 뉴스 데이터 관련
    
    func newsItem(at index: Int) -> NewsItemViewModel {
        return self.newsItemViewModel[index]
    }
    
}

//MARK: - 뉴스 아이템 1개에 대한 뷰모델

// 뉴스 아이템(셀) 하나하나에 대한 뷰모델
final class NewsItemViewModel {
    
    let news: News
    
    init(_ news: News) {
        self.news = news
    }
    
    var title: Observable<String> {
        let string = news.title.unescape()
        return Observable<String>.just(string)
    }
    
    var description: Observable<String> {
        let string = news.description.unescape()
        return Observable<String>.just(string)
    }
    
    var publishDate: Observable<String> {
        // news.pubDate를 date format을 이용해 date 타입으로 변경
        guard let targetDate = news.pubDate.toDate(mode: .news) else { fatalError("date error...") }
        // date를 파라미터로 전달하여 현지 시간과의 차이 구하기
        let interval = Date().getTimeIntervalString(since: targetDate)
        return Observable<String>.just(interval)
    }
    
    var newsPageLink: Observable<String> {
        let string = news.originalLink
        return Observable<String>.just(string)
    }
    
    var fetchDate: Observable<String> {
        return Observable<String>.just("")
    }
    
}
