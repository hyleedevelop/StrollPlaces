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
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupInitialView()
        setupTableView()
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
        // UserDefaults에 저장되어있는 값이 참이면 초기화면 표출
        let isListExist = self.userDefaults.bool(forKey: "myPlaceExist")
        _  = isListExist ? self.hideInitialView() : self.showInitialView()
    }
    
    // TableView 설정
    private func setupTableView() {
        self.myPlaceTableView.delegate = self
        self.myPlaceTableView.dataSource = self
        self.myPlaceTableView.register(UINib(nibName: K.MyPlace.cellName, bundle: nil),
                                       forCellReuseIdentifier: K.MyPlace.cellName)
        self.myPlaceTableView.backgroundColor = UIColor.white
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
                                                       for: indexPath) as? MyPlaceTableViewCell
        else { fatalError("MyPlaceTableViewCell is not found") }
        
        //self.viewModel.getDataSource(at: indexPath.row)
        
        let dataSource = self.viewModel.itemViewModel.trackData[indexPath.row]

        cell.nameLabel.text = dataSource.name.count == 0 ? "제목없음" : dataSource.name
        cell.timeLabel.text = "⏱️ \(dataSource.time)"
        cell.distanceLabel.text = dataSource.distance < 1000.0
        ? "📍 " + String(format: "%.1f", dataSource.distance) + "m"
        : "📍 " + String(format: "%.2f", dataSource.distance) + "km"
        cell.dateLabel.text = "📆 \(dataSource.date)"
        
        return cell
    }
    
}
