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

class MyPlaceViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var myPlaceCollectionView: UICollectionView!
    
    //MARK: - normal property
    
    private lazy var viewModel = MyPlaceViewModel()
    private let userDefaults = UserDefaults.standard
    private let flowLayout = UICollectionViewFlowLayout()  // 컬렉션뷰의 레이아웃을 담당하는 객체
    //private var actions = [UIAction]()
    
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

        self.setupNavigationBar()
        self.setupInitialView()
        self.setupCollectionView()
        self.setupNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Navigation Bar 기본 설정
        navigationController?.applyCommonSettings()
        self.navigationController?.navigationBar.isHidden = false
        
        let isListEmpty = !self.userDefaults.bool(forKey: "myPlaceExist")
        _  = isListEmpty ? self.showInitialView() : self.hideInitialView()

        if !isListEmpty {
            DispatchQueue.main.async {
                self.myPlaceCollectionView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        // Navigation Bar 기본 설정
        navigationController?.applyCommonSettings()
        
        // 좌측 상단에 위치한 타이틀 설정
        navigationItem.makeLeftSideTitle(title: "나만의 산책길")
        
        // right bar button 설정
        let addBarButton = self.navigationItem.makeSFSymbolButton(
            self, action: #selector(pushViewController), symbolName: "plus"
        )
        let sortBarButton = self.navigationItem.makeSFSymbolButton(
            self, menu: self.viewModel.getSortContextMenu(), symbolName: "arrow.up.arrow.down"
        )
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 15
        self.navigationItem.rightBarButtonItems = [addBarButton, spacer, sortBarButton]
    }
    
    // 나만의 산책로 리스트가 없는 경우 애니메이션 표출 설정
    private func setupInitialView() {
        self.viewModel.itemViewModel.shouldShowAnimationView
            .debug("애니메이션 표출")
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
    private func setupReloadOfCollectionView() {
        self.viewModel.itemViewModel.shouldReloadCollectionView.asObservable()
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldReload in
                guard let self = self else { return }
                if shouldReload { self.myPlaceCollectionView.reloadData() }
            })
            .disposed(by: rx.disposeBag)
    }
    
    // Notification을 받았을 때 수행할 내용 설정
    @objc private func notificationReceived(_ notification: NSNotification) {
        let isListEmpty = !self.userDefaults.bool(forKey: "myPlaceExist")
        _  = isListEmpty ? self.showInitialView() : self.hideInitialView()
    }
    
    @objc private func pushViewController() {
        self.performSegue(withIdentifier: "ToTrackingViewController", sender: self)
        
//        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ToTrackingViewController") else { return }
//        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ToDetailInfoViewController" {
//            guard let vc = segue.destination as? NaviViewController else { return }
//            vc.index = message
//        }
    }
    
}

//MARK: - extension for UITableViewDelegate, UITableViewDataSource

extension MyPlaceViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: - directly called method
    
    // section의 개수
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
        
    // section 내 아이템의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getNumberOfMyPlaces()
    }
    
    // 각 셀마다 실행할 내용
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.MyPlace.cellName, for: indexPath)
                as? MyPlaceCollectionViewCell else { return UICollectionViewCell() }
        
        let dataSource = self.viewModel.itemViewModel.sortedTrackData[indexPath.row]
        
        cell.levelRating.rating = dataSource.level
        
        cell.mainImage.image = self.viewModel.loadImageFromDocumentDirectory(
            imageName: dataSource._id.stringValue
        )
        
        cell.nameLabel.text = dataSource.name.count == 0 ? "제목없음" : dataSource.name
        cell.timeLabel.text = "\(dataSource.time)"
        cell.distanceLabel.text = dataSource.distance < 1000.0
        ? String(format: "%.1f", dataSource.distance) + "m"
        : String(format: "%.2f", dataSource.distance/1000.0) + "km"
        cell.dateLabel.text = "\(Int.random(in: 0..<60))분 전"
        
        cell.moreButton.showsMenuAsPrimaryAction = true
        cell.moreButton.menu = self.getMoreContextMenu(index: indexPath.row,
                                                       sender: cell.moreButton)
        
        cell.nameLabel.hero.id = "nameLabel\(indexPath.row)"
        
        return cell
    }
    
    // 셀이 선택되었을 때 실행할 내용
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailInfoViewController") as? DetailInfoViewController else { return }
        nextVC.cellIndex = indexPath.row
        nextVC.modalPresentationStyle = .overFullScreen
        nextVC.hero.isEnabled = true
        nextVC.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)

        self.present(nextVC, animated: true, completion: nil)
    }
    
    //MARK: - indirectly called method
    
    private func getMoreContextMenu(index: Int, sender: UIButton) -> UIMenu {
        let actions = [
            UIAction(title: "삭제", image: UIImage(systemName: "trash"),
                     attributes: .destructive, handler: { _ in
                         self.removeMyPlace(sender, index: index)
                     }),
            UIAction(title: "공유", image: UIImage(systemName: "square.and.arrow.up"),
                     attributes: .keepsMenuPresented, handler: { _ in
                         self.shareMyPlace(sender)
                     }),
        ]
        return UIMenu(title: "", options: [.displayInline], children: actions)
    }
    
    // 나만의 산책길 항목 삭제하기
    private func removeMyPlace(_ sender: UIButton, index: Int) {
        let alert = UIAlertController(
            title: "확인",
            message: "선택한 나만의 산책길을 삭제할까요?\n한번 삭제하면 복구할 수 없습니다.",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "아니요", style: .default)
        let okAction = UIAlertAction(title: "네", style: .destructive) { _ in
            // 정렬된 셀에서 indexPath.row번째 cell에 해당하는 ID
            let sortedDataID = self.viewModel.itemViewModel.sortedTrackData[index]._id
            let realmDB = self.viewModel.itemViewModel.trackData
            
            if let indexOfRealm = realmDB.firstIndex(where: { $0._id == sortedDataID } ) {
                // DB에서 데이터 삭제
                self.viewModel.removeTrackData(at: indexOfRealm)
                
                // CollectionView에서 셀 삭제
                DispatchQueue.main.async {
                    self.myPlaceCollectionView.reloadData()
                }
                
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
    }
    
    // 나만의 산책길 항목 공유하기
    private func shareMyPlace(_ sender: UIButton) {
        
    }
    
}
