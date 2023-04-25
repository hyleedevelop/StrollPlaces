//
//  MyPlaceViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import CoreLocation
import Lottie
import RealmSwift
import SPIndicator

class MyPlaceViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var myPlaceTableView: UITableView!
    
    //MARK: - normal property

    private let viewModel = MyPlaceViewModel()
    private let userDefaults = UserDefaults.standard
    
    //MARK: - UI property
    
    private let initialView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var initialAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "notFound")
        view.frame = self.initialView.bounds
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.animationSpeed = 1.0
        view.play()
        return view
    }()
    
    private let initialTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = UIColor.black
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "아직 나만의 산책길이 없어요 "
        return label
    }()
    
    private let initialSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor.lightGray
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "오른쪽 상단의 + 버튼을 눌러서" + "\n" + "나만의 산책길을 만들어 보세요!"
        return label
    }()
    
    lazy var menuItems: [UIAction] = {
        return self.viewModel.getContextMenuItems()
    }()
    
    lazy var menu: UIMenu = {
        return self.viewModel.getContextMenu()
    }()
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupInitialView()
        setupTableView()
        setupNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let isListEmpty = !self.userDefaults.bool(forKey: "myPlaceExist")
        _  = isListEmpty ? self.showInitialView() : self.hideInitialView()

        if !isListEmpty {
            DispatchQueue.main.async {
                self.myPlaceTableView.reloadData()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundColor = UIColor.white
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNeedsStatusBarAppearanceUpdate()

        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        // left bar button을 누르면 context menu가 나타나도록 설정
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down"), menu: self.menu
        )
        self.navigationItem.leftBarButtonItem?.tintColor = K.Color.themeYellow
    }
    
    // 나만의 산책로 리스트가 없는 경우 애니메이션 표출 설정
    private func setupInitialView() {
        self.viewModel.itemViewModel.shouldShowAnimationView
            .debug("애니메이션 표출")
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldBeShown in
                guard let self = self else { return }
                if shouldBeShown {
                    self.showInitialView()
                } else {
                    self.hideInitialView()
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    // TableView 설정
    private func setupTableView() {
        self.myPlaceTableView.delegate = self
        self.myPlaceTableView.dataSource = self
        self.myPlaceTableView.register(UINib(nibName: K.MyPlace.cellName, bundle: nil),
                                       forCellReuseIdentifier: K.MyPlace.cellName)
        self.myPlaceTableView.backgroundColor = UIColor.white
        self.myPlaceTableView.tableHeaderView = UIView()
        self.myPlaceTableView.tableFooterView = UIView()
        
        self.setupReloadOfTableView()
    }
    
    // Notification을 받았을 때 수행할 내용 설정
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(notificationReceived(_:)),
            name: Notification.Name("showLottieAnimation"), object: nil
        )
    }
    
    //MARK: - indirectly called method
    
    // initial view 추가
    private func showInitialView() {
        self.view.addSubview(self.initialView)
        
        [initialAnimationView, initialTitleLabel, initialSubtitleLabel]
            .forEach { self.initialView.addSubview($0) }
        
        self.initialView.snp.makeConstraints {
            $0.top.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.initialAnimationView.snp.makeConstraints {
            $0.top.equalTo(self.initialView).offset(50)
            $0.left.equalTo(self.initialView).offset(50)
            $0.right.equalTo(self.initialView).offset(-50)
            $0.height.equalTo(250)
        }
        
        self.initialTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.initialAnimationView.snp.bottom).offset(50)
            $0.left.equalTo(self.initialView.safeAreaLayoutGuide).offset(50)
            $0.right.equalTo(self.initialView.safeAreaLayoutGuide).offset(-50)
            $0.height.equalTo(25)
        }
        
        self.initialSubtitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.initialTitleLabel.snp.bottom).offset(50)
            $0.left.equalTo(self.initialView.safeAreaLayoutGuide).offset(50)
            $0.right.equalTo(self.initialView.safeAreaLayoutGuide).offset(-50)
            $0.height.equalTo(45)
        }
    }
    
    // initial view 삭제
    private func hideInitialView() {
        self.initialView.removeFromSuperview()
    }
    
    // context menu를 통해 목록 정렬 기준이 정해지면 메인쓰레드에서 TableView를 reload 하도록 설정
    private func setupReloadOfTableView() {
        self.viewModel.itemViewModel.shouldReloadTableView.asObservable()
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldReload in
                guard let self = self else { return }
                if shouldReload { self.myPlaceTableView.reloadData() }
            })
            .disposed(by: rx.disposeBag)
    }
    
    // Notification을 받았을 때 수행할 내용 설정
    @objc private func notificationReceived(_ notification: NSNotification) {
        let isListEmpty = !self.userDefaults.bool(forKey: "myPlaceExist")
        _  = isListEmpty ? self.showInitialView() : self.hideInitialView()
    }
    
}

//MARK: - extension for UITableViewDelegate, UITableViewDataSource

extension MyPlaceViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - directly called method
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getNumberOfMyPlaces()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.MyPlace.cellName,
                                                       for: indexPath) as? MyPlaceTableViewCell
        else { fatalError("MyPlaceTableViewCell is not found") }
        
        let dataSource = self.viewModel.itemViewModel.sortedTrackData[indexPath.row]

        cell.nameLabel.text = dataSource.name.count == 0 ? "제목없음" : dataSource.name
        cell.timeLabel.text = "⏱️ \(dataSource.time)"
        cell.distanceLabel.text = dataSource.distance < 1000.0
        ? "📍 " + String(format: "%.1f", dataSource.distance) + "m"
        : "📍 " + String(format: "%.2f", dataSource.distance/1000.0) + "km"
        cell.dateLabel.text = "📆 \(dataSource.date)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function, indexPath.row, self.viewModel.itemViewModel.trackpoint.count)
    }
    
    // TableView Cell을 스와이프 했을 때의 action 설정
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 셀 삭제 action 생성
        let deleteAction = self.createDeleteAction(tableView: tableView, indexPath: indexPath)
        // 필요한 경우 기타 다른 action 추가 생성 가능
        // let anotherAction = ...
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
        // return UISwipeActionsConfiguration(actions: [deleteAction, anotherAction, ...])
    }
    
    //MARK: - indirectly called method
    
    private func createDeleteAction(tableView: UITableView, indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            let alert = UIAlertController(title: "확인",
                                          message: "선택한 나만의 산책길을 삭제할까요?\n한번 삭제하면 복구할 수 없습니다.",
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "아니요", style: .default)
            let okAction = UIAlertAction(title: "네", style: .destructive) { _ in
                // 정렬된 셀에서 indexPath.row번째 cell에 해당하는 ID
                let sortedDataID = self.viewModel.itemViewModel.sortedTrackData[indexPath.row]._id
                let realmDB = self.viewModel.itemViewModel.trackData
                
                if let indexOfRealm = realmDB.firstIndex(where: { $0._id == sortedDataID } ) {
                    // Realm DB에서 삭제하기
                    self.viewModel.removeTrackData(at: indexOfRealm)
                    // TableView에서 삭제하기
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    // 화면 상단에 완료 메세지 보여주기
                    SPIndicatorView(title: "삭제 완료", preset: .done)
                        .present(duration: 2.0, haptic: .success)
                } else {
                    // 화면 상단에 에러 메세지 보여주기
                    SPIndicatorView(title: "삭제 실패", preset: .error)
                        .present(duration: 2.0, haptic: .error)
                }
            }
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            // 메세지 보여주기
            self.present(alert, animated: true, completion: nil)
            
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = UIColor.systemRed
        
        return deleteAction
    }
}
