//
//  TimelineViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/04.
//

import UIKit

final class FeedViewController: UIViewController {

    //MARK: - IB outlet & action

    @IBOutlet weak var tableView: UITableView!
        
    //MARK: - property
    
    private let viewModel = FeedViewModel()
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupTableView()
        //self.setupRefreshControl()
        //self.setupActivityIndicator()
        //self.setupScrollToTopView()
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
        navigationItem.makeLeftSideTitle(title: "산책 스토리")
        
//        // right bar button 설정
//        let addBarButton = self.navigationItem.makeCustomSymbolButton(
//            self, action: #selector(pushToTracking), symbolName: "icons8-add-new-100"
//        )
//        let sortBarButton = self.navigationItem.makeCustomSymbolButton(
//            self, menu: self.viewModel.sortContextMenu, symbolName: "icons8-sort-100"
//        )
//        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        spacer.width = 15
//
//        self.navigationItem.rightBarButtonItems = [addBarButton, spacer, sortBarButton]
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
    
}

// MARK: - Extension for TableView

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.numberOfRowsInSection(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
