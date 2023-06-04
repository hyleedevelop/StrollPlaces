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
import Lottie

final class NewsViewController: UIViewController {

    //MARK: - IB outlet & action

    @IBOutlet weak var tableView: UITableView!
        
    //MARK: - property
    
    private var viewModel: NewsViewModel!
    private var scrollToTop = true
    
    private lazy var scrollToTopView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.layer.cornerRadius = 25
        view.backgroundColor = UIColor.black
        view.alpha = 0.5
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    private lazy var scrollToTopImageView: UIImageView = {
        let tapScrollDown = UITapGestureRecognizer(target: self, action: #selector(scrollToTheTop(_:)))
        let iv = UIImageView(frame: CGRect.zero)
        iv.image = UIImage(systemName: "arrow.up")
        iv.image = iv.image!.withRenderingMode(.alwaysTemplate)
        iv.tintColor = UIColor.white
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tapScrollDown)
        return iv
    }()
    
    // refresh control
    private var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.backgroundColor = UIColor.white
        control.tintColor = UIColor.black
        control.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        return control
    }()
    
    // 로딩 아이콘
    private let activityIndicator: NVActivityIndicatorView = {
        let activityIndicator = NVActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: 40, height: 40),
            type: .ballPulseSync,
            color: K.Color.themeRed,
            padding: .zero)
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    
    // 화면을 맨 위의 셀로 이동하는 버튼
    private let scrollToTopButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupTableView()
        self.setupRefreshControl()
        self.setupActivityIndicator()
        self.setupScrollToTopView()
        
        self.fetchNews(searchKeyword: K.News.keyword)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Navigation Bar 기본 설정
        self.navigationController?.applyCustomSettings()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Navigation Bar 기본 설정
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        // Navigation Bar 기본 설정
        navigationController?.applyCustomSettings()
        
        // 좌측 상단에 위치한 타이틀 설정
        navigationItem.makeLeftSideTitle(title: "산책길 관련 소식")
        
//        // right bar button 설정
//        let markBarButton = self.navigationItem.makeSFSymbolButton(
//            self, action: #selector(pushToBookmark), symbolName: "bookmark"
//        )
//        self.navigationItem.rightBarButtonItems = [markBarButton]
    }
    
    // TableView 설정
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: K.News.cellName, bundle: nil),
                                forCellReuseIdentifier: K.News.cellName)
        self.tableView.backgroundColor = UIColor.white
        self.tableView.scrollsToTop = true
    }
    
    // RefreshControl 설정
    private func setupRefreshControl() {
        self.tableView.refreshControl = self.refreshControl
        
        // 초기값 설정
        self.refreshControl.endRefreshing()
        
        let refreshLoading = PublishRelay<Bool>()
        self.refreshControl.rx.controlEvent(.valueChanged)
            //.debounce(.seconds(3), scheduler: MainScheduler.instance)
            .throttle(.seconds(5), scheduler: MainScheduler.instance)  // 무분별한 새로고침 방지
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                
                // 로딩 표시
                refreshLoading.accept(true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    // 뉴스 다시 불러오기
                    self.fetchNews(searchKeyword: K.News.keyword)
                    // 로딩 숨기기
                    refreshLoading.accept(false)
                }
            })
            .disposed(by: rx.disposeBag)
        
        // 바인딩
        refreshLoading
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: rx.disposeBag)
    }
    
    // activity indicator 설정
    private func setupActivityIndicator() {
        self.view.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    // 맨 위로 가기 버튼(뷰) 설정
    private func setupScrollToTopView() {
        self.view.addSubview(scrollToTopView)
        self.scrollToTopView.addSubview(scrollToTopImageView)
        
        self.scrollToTopView.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(-60)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.scrollToTopImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    //MARK: - indirectly called method
    
    // 네이버 API를 통해 뉴스 기사 가져오기
    private func fetchNews(searchKeyword: String) {
        // indicator 활성화
        self.activityIndicator.startAnimating()
        
        // API 요청을 위한 resource 설정
        var resource: Resource<NewsResponse> {
            let urlString = "https://openapi.naver.com/v1/search/news.json?query=\(searchKeyword)&display=100&sort=date"
            return Resource<NewsResponse>(urlRequest: urlString.toURLRequest())
        }
        
        // 뉴스를 가져와서 TableView에 표출하기
        self.displayNewsOnTableView(resource: resource)
    }
    
    // API로 뉴스 가져오기 및 TableView 표출
    private func displayNewsOnTableView(resource: Resource<NewsResponse>) {
        URLRequest.load(resource: resource)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] newsResponse in
                guard let self = self else { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // ViewModel 초기화
                    self.viewModel = NewsViewModel(newsResponse.items)
                    
                    // TableView 갱신
                    self.tableView.reloadData()
                    
                    // 셀 표출 관련 애니메이션
                    let cells = self.tableView.visibleCells(in: 0)
                    let animations = [AnimationType.vector(CGVector(dx: 0, dy: 20))]
                    UIView.animate(views: cells, animations: animations, duration: 1.0)
                    
                    // indicator 비활성화
                    self.activityIndicator.stopAnimating()

                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    // scrollToTop 버튼의 레이아웃 설정
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        // 스크롤 offset이 400 이상이면 버튼 나타내기
        if offsetY >= 400 {
            if self.scrollToTop {
                self.scrollToTopView.snp.updateConstraints {
                    $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(25)
                }
                UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
                self.scrollToTop = false
            }
        // 스크롤 offset이 400 미만이면 버튼 숨기기
        } else {
            if !self.scrollToTop {
                self.scrollToTopView.snp.updateConstraints {
                    $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(-60)
                }
                UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
                self.scrollToTop = true
            }
        }
    }
    
    // 뉴스 책갈피 화면으로 이동
    @objc private func pushToBookmark() {
        //self.performSegue(withIdentifier: "ToTrackingViewController", sender: self)
        print("책갈피 화면으로 이동합니다.")
    }
    
    @objc private func scrollToTheTop(_ sender: UITapGestureRecognizer) {
        let topOffest = CGPoint(x: 0, y: -(self.tableView?.contentInset.top ?? 0))
        self.tableView.setContentOffset(topOffest, animated: true)
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
                $0.top.equalToSuperview().offset(25)
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
