//
//  SettingViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SafariServices
import MessageUI

final class MoreViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - property
    
    internal let viewModel = MoreViewModel()
    internal let userDefaults = UserDefaults.standard
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupLabel()
        self.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Navigation Bar 기본 설정
        navigationController?.applyCustomSettings()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Navigation Bar 기본 설정
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        // Navigation Bar 기본 설정
        navigationController?.applyCustomSettings()
        
        // 좌측 상단에 위치한 타이틀 설정
        navigationItem.makeLeftSideTitle(title: "더보기")
    }
    
    // Label 설정
    private func setupLabel() {
        self.nicknameLabel.text = "\(self.viewModel.nicknameString)님"
    }
    
    // TableView 설정
    private func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "MoreTableViewCell", bundle: nil),
                                forCellReuseIdentifier: "MoreCell")
        self.tableView.backgroundColor = UIColor.white
        self.tableView.separatorStyle = .none
        //self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        self.viewModel.shouldReloadTableView.asObservable()
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] needToBeReloaded in
                guard let self = self else { return }
                if needToBeReloaded { self.tableView.reloadData() }
            })
            .disposed(by: rx.disposeBag)
    }
    
}

//MARK: - extension for MFMailComposeViewControllerDelegate

extension MoreViewController: MFMailComposeViewControllerDelegate {

    

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
