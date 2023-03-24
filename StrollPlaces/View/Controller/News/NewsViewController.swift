//
//  NewsViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/24.
//

import UIKit
import RxSwift
import RxCocoa

final class NewsViewController: UIViewController {

    //MARK: - property
    
    private var newsListViewModel: NewsListViewModel!
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        
        populateNews()
    }
    
    //MARK: - method
    
    // TableView 설정
    private func setupTableView() {
        
    }

    // 뉴스 가져오기
    private func populateNews() {
//        let urlString = "https://newsapi.org/v2/top-headlines?country=us&apiKey=ba83fc34c5be4e04bf025cb1888b83b1"
//        let resource = Resource<NewsResponse>(url: URL(string: urlString)!)
//
//        URLRequest.load(resource: resource)
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] newsResponse in
//                guard let self = self else { return }
//                let news = newsResponse.newsList  // [Article]
//                self.newsListViewModel = NewsListViewModel(news)
//
//                self.tableView.reloadData()
//            })
//            .disposed(by: rx.disposeBag)
    }

}

// MARK: - Extension for Table View

//extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.articleListViewModel == nil ? 0 : self.articleListViewModel.articleVM.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell",
//                                                       for: indexPath) as? ArticleTableViewCell else { fatalError("ArticleTableViewCell is not found") }
//
//        let articleViewModel = self.articleListViewModel.articleAt(indexPath.row)
//
//        articleViewModel.title.asDriver(onErrorJustReturn: "")
//            .drive(cell.titleLabel.rx.text)
//            .disposed(by: bag)
//
//        articleViewModel.description.asDriver(onErrorJustReturn: "")
//            .drive(cell.descriptionLabel.rx.text)
//            .disposed(by: bag)
//
//        return cell
//    }
//
//}
