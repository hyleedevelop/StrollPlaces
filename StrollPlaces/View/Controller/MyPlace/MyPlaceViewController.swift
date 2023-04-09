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
//import ActivityKit
import Lottie
import RealmSwift

class MyPlaceViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var myPlaceTableView: UITableView!
    
    //MARK: - normal property

    private let viewModel = MyPlaceViewModel()
    private let userDefaults = UserDefaults.standard
    
    // TrackPoint를 DB로부터 Read하여 담을 변수
    var TrackDatas: Results<TrackData>!
    // TrackPoint 업데이트 시 사용할 변수
    var notificationToken: NotificationToken?
    
    
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
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupInitialView()
        setupTableView()

        setupRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let isListEmpty = !self.userDefaults.bool(forKey: "testSwitchValue")
        _  = isListEmpty ? self.showInitialView() : self.hideInitialView()
    }
    
    deinit {
        // notification을 받는 쪽에서 observer 제거
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
    }
    
    // 나만의 산책로 리스트가 없는 경우 표시할 View 설정
    private func setupInitialView() {
        let isListExist = self.userDefaults.bool(forKey: "testSwitchValue")
        print("MyPlaceViewController", isListExist, separator: ", ")
        
        // UserDefaults에 저장되어있는 값이 참이면 초기화면 표출
        _  = isListExist ? self.hideInitialView() : self.showInitialView()
    }
    
    // CollectionView 설정
    private func setupTableView() {
        self.myPlaceTableView.delegate = self
        self.myPlaceTableView.dataSource = self
        self.myPlaceTableView.register(UINib(nibName: K.MyPlace.cellName, bundle: nil),
                                       forCellReuseIdentifier: K.MyPlace.cellName)
        self.myPlaceTableView.backgroundColor = UIColor.white
    }
    
    // Realm DB 설정
    private func setupRealm() {
        let realm = RealmService.shared.realm
        self.TrackDatas = realm.objects(TrackData.self)
        
        notificationToken = TrackDatas.observe { (changes) in
            self.myPlaceTableView.reloadData()
        }
    }
    
    //MARK: - indirectly called method
    
    // initial view 추가
    private func showInitialView() {
        self.view.addSubview(self.initialView)
        self.initialView.addSubview(initialAnimationView)
        self.initialView.addSubview(initialTitleLabel)
        self.initialView.addSubview(initialSubtitleLabel)
        
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
    
}

//MARK: - extension for UITableViewDelegate, UITableViewDataSource

extension MyPlaceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getNumberOfMyPlaces()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.MyPlace.cellName,
                                                       for: indexPath) as? MyPlaceTableViewCell else { fatalError("MyPlaceTableViewCell is not found")}
        
        // viewModel의 Relay에서 요소 방출
        self.viewModel.loadTableViewCell(at: indexPath.row)
        
        // 바인딩
        self.viewModel.mainImageRelay.asDriver(onErrorJustReturn: UIImage())
            .drive(cell.mainImage.rx.image)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.nameRelay.asDriver(onErrorJustReturn: "N/A")
            .drive(cell.nameLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.timeRelay.asDriver(onErrorJustReturn: "N/A")
            .drive(cell.timeLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.distanceRelay.asDriver(onErrorJustReturn: "N/A")
            .drive(cell.distanceLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.dateRelay.asDriver(onErrorJustReturn: "N/A")
            .drive(cell.dateLabel.rx.text)
            .disposed(by: rx.disposeBag)
                
        return cell
    }
    
}

//MARK: - extension for CLLocationManagerDelegate

extension MyPlaceViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last {
//            currentLocationLabel.text = "위도: \(location.coordinate.latitude)°" + "\n" +
//                                        "경도: \(location.coordinate.longitude)°"
//        }
    }
    
}
