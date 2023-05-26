//
//  DetailViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/19.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import CoreLocation
import SPIndicator
import FaveButton

class PlaceInfoViewController: UIViewController {
    
    //MARK: - UI property
    
    internal lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    internal let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = K.Shape.largeCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: -3)
        view.layer.shadowRadius = 3
        return view
    }()
    
    private lazy var faveButton: FaveButton = {
        let button = FaveButton(
            frame: CGRect(x:0, y:0, width: 30, height: 30),
            faveIconNormal: UIImage(systemName: "star.fill")
        )
        button.selectedColor = K.Color.themeYellow
        button.dotFirstColor = K.Color.themeYellow
        button.dotSecondColor = UIColor.orange
        button.circleToColor = K.Color.themeYellow
        button.delegate = self
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    internal let disclosureButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        button.backgroundColor = UIColor.systemGray6
        button.tintColor = UIColor.black
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        return button
    }()
    
    public let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor.darkGray
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    public let expectedTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor.darkGray
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [distanceLabel, expectedTimeLabel])
        sv.axis = .horizontal
        sv.spacing = 20
        sv.alignment = .leading
        sv.distribution = .fillProportionally
        return sv
    }()
    
    public let navigateButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = K.Color.mainColor
        button.setTitle(K.DetailView.navigateButtonName, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.tintColor = UIColor.white
        button.layer.cornerRadius = K.Shape.mediumCornerRadius
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [navigateButton])
        sv.axis = .horizontal
        sv.spacing = 30
        sv.alignment = .fill
        sv.distribution = .fillEqually
        return sv
    }()
    
    internal let tableView: UITableView = {
        let tv = UITableView()
        tv.allowsSelection = false
        tv.separatorStyle = .none
        tv.scrollsToTop = true
        tv.showsVerticalScrollIndicator = true
        tv.alpha = 0.0
        return tv
    }()
    
    //MARK: - normal property
    
    internal var viewModel: PlaceInfoViewModel!
    var isDetailActivated = false
    var isFaveButtonActivated = BehaviorSubject<Bool>(value: false)
    
    internal let maxDimmedAlpha: CGFloat = 0.15  // 값이 0이면 투명 -> 탭 해도 dismiss가 일어나지 않음
    //internal let defaultHeight: CGFloat = 150 + (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)

    private let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    internal let dismissibleHeight: CGFloat = 160
    internal lazy var defaultHeight: CGFloat = 180 + (scene?.windows.first?.safeAreaInsets.bottom ?? 0)
    internal lazy var currentContainerHeight: CGFloat = 180 + (scene?.windows.first?.safeAreaInsets.bottom ?? 0)
    internal let maximumContainerHeight: CGFloat = 500
    internal var maximumContainerHeightByButton: CGFloat = 500
    
    // Dynamic container constraint
    //internal var containerViewHeightRelay = BehaviorRelay<CGFloat>(value: 190)
    internal var containerViewHeightConstraint: NSLayoutConstraint?
    internal var containerViewBottomConstraint: NSLayoutConstraint?
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        self.setupTopUI()
        self.setupMiddleUI()
        self.setupBottomUI()
        
        self.setupConstraints()
        
        self.setupTapGesture()
        self.setupPanGesture()
        
        self.setupBinding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    //MARK: - directly called method

    private func setupView() {
        // view
        self.view.backgroundColor = .clear
        
        // dimmed view
        self.view.addSubview(self.dimmedView)
        self.dimmedView.snp.makeConstraints {
            $0.left.right.top.bottom.equalTo(self.view)
        }
        
        // container view
        self.view.addSubview(self.containerView)
        self.containerView.snp.makeConstraints {
            $0.left.right.equalTo(self.view)
        }
    }
    
    private func setupTopUI() {
        // fave button
        self.containerView.addSubview(self.faveButton)
        self.faveButton.snp.makeConstraints {
            $0.top.equalTo(self.containerView.safeAreaLayoutGuide).offset(20)
            $0.left.equalTo(self.containerView.safeAreaLayoutGuide).offset(K.Shape.horizontalSafeAreaOffset)
            $0.height.equalTo(30)
            $0.width.equalTo(30)
        }
        
        // disclosure button
        self.containerView.addSubview(self.disclosureButton)
        self.disclosureButton.snp.makeConstraints {
            $0.top.equalTo(self.containerView.safeAreaLayoutGuide).offset(20)
            $0.right.equalTo(self.containerView.safeAreaLayoutGuide).offset(-K.Shape.horizontalSafeAreaOffset)
            $0.width.height.equalTo(30)
        }
        
        // name label
        self.containerView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints {
            $0.top.equalTo(self.containerView.safeAreaLayoutGuide).offset(20)
            $0.left.equalTo(self.faveButton.snp.right).offset(10)
            $0.right.equalTo(self.disclosureButton.snp.left).offset(-20)
            $0.height.equalTo(30)
        }
    }
    
    private func setupMiddleUI() {
        self.containerView.addSubview(self.labelStackView)
        self.labelStackView.snp.makeConstraints {
            $0.top.equalTo(self.faveButton.snp.bottom).offset(20)
            $0.left.equalTo(self.containerView.safeAreaLayoutGuide).offset(K.Shape.horizontalSafeAreaOffset)
            $0.width.greaterThanOrEqualTo(100)
            $0.height.equalTo(18)
//            $0.width.equalTo(390)
        }
        
//        self.typeLabel.snp.makeConstraints {
//            $0.width.equalTo(120)
//        }
//
//        self.distanceLabel.snp.makeConstraints {
//            $0.width.equalTo(100)
//        }
//
//        self.expectedTimeLabel.snp.makeConstraints {
//            $0.width.equalTo(150)
//        }
    }
    
    private func setupBottomUI() {
        self.containerView.addSubview(self.buttonStackView)
        self.buttonStackView.snp.makeConstraints {
            $0.top.equalTo(self.labelStackView.snp.bottom).offset(20)
            $0.left.equalTo(self.containerView.safeAreaLayoutGuide).offset(K.Shape.horizontalSafeAreaOffset)
            $0.right.equalTo(self.containerView.safeAreaLayoutGuide).offset(-K.Shape.horizontalSafeAreaOffset)
            $0.height.equalTo(50)
        }
    }
    
    internal func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "PlaceInfoTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "PlaceInfoCell")
        self.tableView.showsVerticalScrollIndicator = true
        
        self.containerView.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.navigateButton.snp_bottomMargin).offset(25)
            $0.left.right.equalTo(self.containerView.safeAreaLayoutGuide)
            //$0.height.equalTo(300)
            $0.bottom.equalTo(self.containerView.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    private func setupBinding() {
        let placeName = self.viewModel.getPlaceName().asDriver(onErrorJustReturn: "알수없음")
        let distance = self.viewModel.estimatedDistance.asDriver(onErrorJustReturn: "알수없음")
        let time = self.viewModel.estimatedTime.asDriver(onErrorJustReturn: "알수없음")
        
        // 장소명
        placeName
            .drive(self.nameLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        // 거리
        distance
            .drive(self.distanceLabel.rx.text)
            .disposed(by: rx.disposeBag)

        // 소요시간
        time
            .drive(self.expectedTimeLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        // "chevron" 버튼을 눌렀을 때 실행할 이벤트
        self.disclosureButton.rx.controlEvent(.touchUpInside).asObservable()
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                if !self.isDetailActivated {
                    self.animateContainerHeight(self.maximumContainerHeightByButton)
                    self.disclosureButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                } else {
                    UIView.animate(withDuration: 0.3) {
                        self.tableView.alpha = 0.0  // TableView 넣기
                    }
                    self.disclosureButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                    self.animateContainerHeight(self.defaultHeight)
                }
                
                self.isDetailActivated.toggle()
            })
            .disposed(by: rx.disposeBag)
        
        // "경로 보기" 버튼을 눌렀을 때 실행할 이벤트
        // -> MapViewController+Annotation.swift에 구현되어 있음
        
        // "즐겨찾기 등록" 버튼을 눌렀을 때 실행할 이벤트
        self.viewModel.checkFaveButton
            .subscribe(onNext: { [weak self] isChecked in
                guard let self = self else { return }
                self.faveButton.isSelected = isChecked
            })
            .disposed(by: rx.disposeBag)
        
        self.faveButton.rx.controlEvent(.touchUpInside).asObservable()
            //.debounce(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(
                onNext: {
                    // 알림 메세지 보여주기
                    let alert = UIAlertController(
                        title: nil,
                        message: "즐겨찾기 기능은\n추후 구현될 예정입니다.",
                        preferredStyle: .alert
                    )
                    self.present(alert, animated: true, completion: nil)
                    Timer.scheduledTimer(
                        withTimeInterval: 2.0, repeats: false,
                        block: { _ in alert.dismiss(animated: true) }
                    )
                    
                    //if ... {
                    //    let indicatorView = SPIndicatorView(title: "즐겨찾기 해제", preset: .done)
                    //}
                    //let indicatorView = SPIndicatorView(title: "등록 완료", preset: .done)
                    //indicatorView.present(duration: 2.0, haptic: .success)
                },
                onError: { _ in
                    //let indicatorView = SPIndicatorView(title: "등록 실패", preset: .error)
                    //indicatorView.present(duration: 2.0, haptic: .error)
                })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - indirectly called method
    
    @objc private func visitWebPage() {
        let url = URL(string: self.viewModel.itemViewModel.homepage)!
        UIApplication.shared.open(url)
    }
    
}

//MARK: - extension for UITableViewDelegate, UITableViewDataSource

extension PlaceInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getNumberOfPlaceInfo()
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 60
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "PlaceInfoCell", for: indexPath) as? PlaceInfoTableViewCell else { fatalError() }
        
        // 데이터 보내기 (3): PlaceVM -> PlaceVC(바인딩)
        self.viewModel.getTitleInfo()
            .asDriver(onErrorJustReturn: ["알수없음"])
            .compactMap { $0[indexPath.row ] }
            .drive(cell.titleLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.getSubtitleInfo()
            .asDriver(onErrorJustReturn: ["알수없음"])
            .compactMap { $0[indexPath.row ] }
            .drive(cell.descriptionLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        if self.viewModel.itemViewModel.infoType == .recreationForest && indexPath.row == 7 {
            if self.viewModel.itemViewModel.homepage != K.Map.noDataMessage {
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.visitWebPage))
                let titleString = "접속하기"
                let attributedLinkString = NSMutableAttributedString(string: titleString)
                cell.descriptionLabel.addGestureRecognizer(tap)
                cell.descriptionLabel.isUserInteractionEnabled = true
                cell.descriptionLabel.attributedText = attributedLinkString
                cell.descriptionLabel.textColor = K.Color.mainColor
            }
        }
        
        return cell
    }
    
}

//MARK: - extension for FaveButtonDelegate

//extension PlaceInfoViewController: FaveButtonDelegate {
//
//    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
//        print("즐겨찾기 버튼 클릭됨...")
//
//        // Realm DB에 즐겨찾기 장소 저장 또는 삭제하기
//        _ = selected ? self.viewModel.addMyPlaceData() : self.viewModel.removeMyPlaceData()
//    }
//
//}
