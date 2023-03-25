//
//  NewsViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import NVActivityIndicatorView

final class NewsViewController: UIViewController {

    //MARK: - IB outlet & action

    @IBOutlet weak var tableView: UITableView!
        
    //MARK: - property
    
    private var viewModel: NewsViewModel!
    private var refreshControl = UIRefreshControl()
    private let activityIndicator: NVActivityIndicatorView = {
        let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50),
                                                        type: .ballRotateChase,
                                                        color: UIColor.black,
                                                        padding: .zero)
        activityIndicator.color = UIColor.black
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupRefreshControl()
        setupLoadingIndicator()
        
        fetchNews(searchKeyword: K.News.keyword)
    }
    
    //MARK: - method
    
    // TableView 설정
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: K.News.cellName, bundle: nil),
                                forCellReuseIdentifier: K.News.cellName)
        self.tableView.alpha = 0.0
    }
    
    // RefreshControl 설정
    private func setupRefreshControl() {
        //refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        
        self.refreshControl.backgroundColor = UIColor.systemGray6
        self.refreshControl.tintColor = UIColor.black
        self.refreshControl.attributedTitle = NSAttributedString(string: "뉴스 업데이트")
        
        self.tableView.refreshControl = self.refreshControl
        
        // 초기값 설정
        self.refreshControl.endRefreshing()
        
        let refreshLoading = PublishRelay<Bool>() // ViewModel에 있다고 가정
        self.refreshControl.rx.controlEvent(.valueChanged)
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                
                // 로딩 표시
                refreshLoading.accept(true)
                
                // 뉴스 다시 불러오기
                self.fetchNews(searchKeyword: K.News.keyword)
                
                refreshLoading.accept(false)
            })
            .disposed(by: rx.disposeBag)
        
        // 바인딩
        refreshLoading
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: rx.disposeBag)
    }
    
    // loading indicator 설정
    private func setupLoadingIndicator() {
        self.view.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalTo(self.view.safeAreaLayoutGuide)
            $0.width.height.equalTo(50)
        }
    }

    // 네이버 뉴스 가져오기
    private func fetchNews(searchKeyword: String) {
        // indicator 활성화
        self.activityIndicator.startAnimating()
        
        // API 요청 설정
        var request: URLRequest {
            let urlString: String = "https://openapi.naver.com/v1/search/news.json?query=\(searchKeyword)&display=100&sort=date"
            let urlStringEncoded: String = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            let queryURL: URL = URL(string: urlStringEncoded)!
            var urlRequest = URLRequest(url: queryURL)
            urlRequest.addValue(K.News.naverClientID, forHTTPHeaderField: "X-Naver-Client-Id")
            urlRequest.addValue(K.News.naverClientKEY, forHTTPHeaderField: "X-Naver-Client-Secret")
            return urlRequest
        }
        
        let resource = Resource<NewsResponse>(urlRequest: request)
        
        URLRequest.load(resource: resource)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] newsResponse in
                guard let self = self else { return }
                
                let news = newsResponse.items
                self.viewModel = NewsViewModel(news)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // TableView 갱신
                    self.tableView.reloadData()
                    
                    // TableView 서서히 보여주기
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 1.5) {
                            self.tableView.alpha = 1.0
                        }
                    }
                    
                    // indicator 비활성화
                    self.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    
}

// MARK: - Extension for Table View

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel == nil ? 0 : self.viewModel.newsItemViewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.News.cellName,
                                                       for: indexPath) as? NewsTableViewCell
        else { fatalError("NewsTableViewCell is not found") }

        let newsItem = self.viewModel.newsItem(at: indexPath.row)

        newsItem.title.asDriver(onErrorJustReturn: "")
            .drive(cell.titleLabel.rx.text)
            .disposed(by: rx.disposeBag)

        newsItem.description.asDriver(onErrorJustReturn: "")
            .drive(cell.descriptionLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        newsItem.publishDate.asDriver(onErrorJustReturn: "")
            .drive(cell.dateLabel.rx.text)
            .disposed(by: rx.disposeBag)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function, indexPath.row)
        //let cell = self.tableView.cellForRow(at: indexPath) as! NewsTableViewCell
        
        
    }
    
}
