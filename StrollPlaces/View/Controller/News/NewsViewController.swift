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
import SafariServices
import ViewAnimator

final class NewsViewController: UIViewController {

    //MARK: - IB outlet & action

    @IBOutlet weak var tableView: UITableView!
        
    //MARK: - property
    
    private var viewModel: NewsViewModel!
    
    // 구글 애드몹
//    lazy var bannerView: GADBannerView = {
//        let banner = GADBannerView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//        return banner
//    }()
    
    // refresh control
    private var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.backgroundColor = UIColor.white
        control.tintColor = UIColor.black
        //control.attributedTitle = NSAttributedString(string: "뉴스 업데이트")
        return control
    }()
    
    // 로딩 아이콘
    private let activityIndicator: NVActivityIndicatorView = {
        let activityIndicator = NVActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: 50, height: 50),
            type: .ballRotateChase,
            color: UIColor.black,
            padding: .zero)
        activityIndicator.color = UIColor.black
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    
    // 맨 위로 올리기 버튼
    private let scrollToTopButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
        setupRefreshControl()
        setupLoadingIndicator()
        
        fetchNews(searchKeyword: K.News.keyword)
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundColor = UIColor.white
//        navigationBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        // scrollEdge: 스크롤 하기 전의 NavigationBar
        // standard: 스크롤을 하고 있을 때의 NavigationBar
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNeedsStatusBarAppearanceUpdate()

        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    // TableView 설정
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: K.News.cellName, bundle: nil),
                                forCellReuseIdentifier: K.News.cellName)
        self.tableView.backgroundColor = UIColor.white
    }
    
    // RefreshControl 설정
    private func setupRefreshControl() {
        self.tableView.refreshControl = self.refreshControl
        
        // 초기값 설정
        self.refreshControl.endRefreshing()
        
        let refreshLoading = PublishRelay<Bool>()
        self.refreshControl.rx.controlEvent(.valueChanged)
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                // 로딩 표시
                refreshLoading.accept(true)
                // 뉴스 다시 불러오기
                self.fetchNews(searchKeyword: K.News.keyword)
                // 로딩 숨기기
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
        let request = createURLRequest(
            urlString: "https://openapi.naver.com/v1/search/news.json?query=\(searchKeyword)&display=100&sort=date"
        )
        let resource = Resource<NewsResponse>(urlRequest: request)
        
        // 뉴스를 가져와서 TableView에 표출하기
        displayNewsOnTableView(resource: resource)
    }
    
    //MARK: - indirectly called method
    
    // URLRequest 구조체 생성
    private func createURLRequest(urlString: String) -> URLRequest {
        let urlStringEncoded: String = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let queryURL: URL = URL(string: urlStringEncoded)!
        var urlRequest = URLRequest(url: queryURL)
        
        urlRequest.addValue(K.News.naverClientID, forHTTPHeaderField: "X-Naver-Client-Id")
        urlRequest.addValue(K.News.naverClientKEY, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        return urlRequest
    }
    
    // API로 뉴스 가져오기 및 TableView 표출
    private func displayNewsOnTableView(resource: Resource<NewsResponse>) {
        URLRequest.load(resource: resource)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] newsResponse in
                guard let self = self else { return }
                
                let news = newsResponse.items
                self.viewModel = NewsViewModel(news)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // TableView 갱신
                    self.tableView.reloadData()
                    
                    // 셀 표출 관련 애니메이션
                    DispatchQueue.main.async {
                        let cells = self.tableView.visibleCells(in: 0)
                        let animations = [AnimationType.vector(CGVector(dx: 0, dy: 30))]
                        UIView.animate(views: cells, animations: animations, duration: 1.0)
                    }
                    
                    // indicator 비활성화
                    self.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
}

// MARK: - Extension for TableView

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
        
        let clearSelectionView = UIView()
        clearSelectionView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = clearSelectionView
        
        if indexPath.row == 0 {
            cell.backView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(20)
            }
            self.view.layoutIfNeeded()
        }

        self.viewModel.newsItem(at: indexPath.row).title.asDriver(onErrorJustReturn: "")
            .drive(cell.titleLabel.rx.text)
            .disposed(by: rx.disposeBag)

        self.viewModel.newsItem(at: indexPath.row).description.asDriver(onErrorJustReturn: "")
            .drive(cell.descriptionLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.newsItem(at: indexPath.row).publishDate.asDriver(onErrorJustReturn: "")
            .drive(cell.dateLabel.rx.text)
            .disposed(by: rx.disposeBag)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀 선택 시 selection이 바로 해제되도록 설정
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        // 뉴스 원문 웹페이지 링크를 가져와서 Safari로 보여주기
        self.viewModel.newsItem(at: indexPath.row).newsPageLink
            .subscribe { [weak self] urlString in
                guard let self = self else { return }
                let websiteURL = NSURL(string: urlString)
                let webView = SFSafariViewController(url: websiteURL! as URL)
                self.present(webView, animated: true, completion: nil)
            }
            .disposed(by: rx.disposeBag)
    }
    
}
