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
import Hero

final class MyPlaceViewController: UIViewController {
    
    //MARK: - IB outlet & action
    
    @IBOutlet weak var myPlaceCollectionView: UICollectionView!
    
    //MARK: - normal property
    
    internal let viewModel = MyPlaceViewModel()
    private let flowLayout = UICollectionViewFlowLayout()  // 컬렉션뷰의 레이아웃을 담당하는 객체
    private var timer = Timer()
    
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
        label.text = "오른쪽 상단의 + 버튼을 눌러서" + "\n" + "나만의 산책길을 만들어보는건 어때요?"
        return label
    }()
        
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupInitialView()
        self.setupCollectionView()
        self.setupNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Navigation Bar 기본 설정
        navigationController?.applyCustomSettings()
        self.navigationController?.navigationBar.isHidden = false
        
        let isListEmpty = !UserDefaults.standard.bool(forKey: K.UserDefaults.isMyPlaceExist)
        _  = isListEmpty ? self.showInitialView() : self.hideInitialView()

        if !isListEmpty {
            DispatchQueue.main.async {
                self.myPlaceCollectionView.reloadData()
            }
        }
        
        // 생성 시각(n분전, n시간 전 등...)을 1분마다 업데이트 하기 위해 Collection View를 갱신하는 Timer 시작
        self.timer = Timer.scheduledTimer(
            timeInterval: 60, target: self, selector: #selector(reloadMyPlace),
            userInfo: nil, repeats: true
        )
        
        // 사용자가 메인쓰레드에서 작업(interaction, UI update 등)중이어도 타이머가 작동되도록 설정
        RunLoop.current.add(self.timer, forMode: .common)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Navigation Bar 기본 설정
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // Collection View를 갱신하는 Timer 해제
        self.timer.invalidate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        // Navigation Bar 기본 설정
        self.navigationController?.applyCustomSettings()
        
        // 좌측 상단에 위치한 타이틀 설정
        self.navigationItem.makeLeftSideTitle(title: "MY산책길")
        
        // right bar button 설정
        let addBarButton = self.navigationItem.makeCustomSymbolButton(
            self, action: #selector(pushToTracking), symbolName: "icons8-add-new-100"
        )
        let sortBarButton = self.navigationItem.makeCustomSymbolButton(
            self, menu: self.viewModel.sortContextMenu, symbolName: "icons8-sort-100"
        )
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 15
        
        self.navigationItem.rightBarButtonItems = [addBarButton, spacer, sortBarButton]
    }
    
    // 나만의 산책로 리스트가 없는 경우 애니메이션 표출 설정
    private func setupInitialView() {
        self.viewModel.itemViewModel.shouldShowAnimationView
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldBeShown in
                guard let self = self else { return }
                _ = shouldBeShown ? self.showInitialView() : self.hideInitialView()
            })
            .disposed(by: rx.disposeBag)
    }
    
    // CollectionView 설정
    private func setupCollectionView() {
        self.view.addSubview(myPlaceCollectionView)
        self.myPlaceCollectionView.snp.makeConstraints {
            $0.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.left.equalTo(self.view.safeAreaLayoutGuide).offset(K.MyPlace.leadingSpacing)
            $0.right.equalTo(self.view.safeAreaLayoutGuide).offset(-K.MyPlace.trailingSpacing)
        }
        
        // delegate 설정
        self.myPlaceCollectionView.delegate = self
        self.myPlaceCollectionView.dataSource = self
        
        // 컬렉션뷰 배경 색상 설정
        self.myPlaceCollectionView.backgroundColor = .clear
        // 컬렉션뷰의 스크롤 방향 설정
        self.flowLayout.scrollDirection = .vertical
        self.myPlaceCollectionView.showsVerticalScrollIndicator = false
        // 컬렉션뷰의 셀 넓이 및 높이 설정
        self.flowLayout.itemSize = CGSize(width: K.MyPlace.cellWidth, height: K.MyPlace.cellHeight)
        // 컬렉션뷰 아이템간의 좌우 간격 설정
        self.flowLayout.minimumInteritemSpacing = K.MyPlace.spacingWidth
        // 컬렉션뷰 아이템간의 상하 간격 설정
        self.flowLayout.minimumLineSpacing = K.MyPlace.spacingHeight
        // 컬렉션뷰의 header 및 footer 크기 설정
        self.flowLayout.headerReferenceSize = CGSize(width: 0, height: K.MyPlace.spacingHeight)
        self.flowLayout.footerReferenceSize = CGSize(width: 0, height: K.MyPlace.spacingHeight)
        
        // 플로우 레이아웃을 컬렉션뷰의 레이아웃에 할당
        self.myPlaceCollectionView.collectionViewLayout = self.flowLayout
        
        // xib 파일 사용을 위해 UINib 오브젝트 등록
        self.myPlaceCollectionView.register(UINib(nibName: K.MyPlace.cellName, bundle: nil),
                                            forCellWithReuseIdentifier: K.MyPlace.cellName)
        self.myPlaceCollectionView.backgroundColor = UIColor.white
        
        // 데이터 갱신에 대한 설정
        self.setupReloadOfCollectionView()
    }
    
    // Notification을 받았을 때 수행할 내용 설정
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(shouldShowAnimation(_:)),
            name: Notification.Name("showLottieAnimation"), object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadMyPlace(_:)),
            name: Notification.Name("reloadMyPlace"), object: nil
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
            $0.top.equalTo(self.initialTitleLabel.snp.bottom).offset(20)
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
    private func setupReloadOfCollectionView() {
        self.viewModel.itemViewModel.collectionViewShouldBeReloaded.asObservable()
            .filter { $0 == true }
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.myPlaceCollectionView.reloadData()
            })
            .disposed(by: rx.disposeBag)
    }
    
    // Notification을 받았을 때 수행할 내용 설정 (1)
    @objc private func shouldShowAnimation(_ notification: NSNotification) {
        let isListEmpty = !self.viewModel.isMyPlaceExist
        _  = isListEmpty ? self.showInitialView() : self.hideInitialView()
    }
    
    // Notification을 받았을 때 수행할 내용 설정 (2)
    @objc private func reloadMyPlace(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.myPlaceCollectionView.reloadData()
        }
    }
    
    // 나만의 산책길 생성 화면으로 이동
    @objc private func pushToTracking() {
        self.performSegue(withIdentifier: "ToTrackingViewController", sender: self)
    }
    
}
