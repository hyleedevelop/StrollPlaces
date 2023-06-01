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
        //button.isSelected = self.viewModel.isChecked
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
    var isFaveButtonActivated = false
    
    internal let maxDimmedAlpha: CGFloat = 0.15  // 값이 0이면 투명 -> 탭 해도 dismiss가 일어나지 않음
    
    private let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    internal let dismissibleHeight: CGFloat = 160
    internal lazy var defaultHeight: CGFloat = 180 + (scene?.windows.first?.safeAreaInsets.bottom ?? 0)
    internal lazy var currentContainerHeight: CGFloat = 180 + (scene?.windows.first?.safeAreaInsets.bottom ?? 0)
    internal let maximumContainerHeight: CGFloat = 500
    internal var maximumContainerHeightByButton: CGFloat = 500
    
    // Dynamic container constraint
    internal var containerViewHeightConstraint: NSLayoutConstraint?
    internal var containerViewBottomConstraint: NSLayoutConstraint?
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        self.setupTopUI()
        self.setupFaveButtonState()
        self.setupMiddleUI()
        self.setupBottomUI()
        
        self.setupConstraints()
        
        self.setupTapGesture()
        self.setupPanGesture()
        
        self.setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupFaveButtonState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.animateShowDimmedView()
        self.animatePresentContainer()
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
    
    private func setupFaveButtonState() {
        self.faveButton.isSelected = self.viewModel.checkPinNumber() ? true : false
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
        let placeName = self.viewModel.placeName.asDriver(onErrorJustReturn: "알수없음")
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
        
        // 펼치기/접기 버튼을 눌렀을 때 실행할 이벤트
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
                    self.animateContainerHeight(self.defaultHeight)
                    self.disclosureButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                }
                
                self.isDetailActivated.toggle()
            })
            .disposed(by: rx.disposeBag)
        
        // "경로 보기" 버튼을 눌렀을 때 실행할 이벤트
        // -> MapViewController+Annotation.swift에 구현되어 있음
        
        // "즐겨찾기 등록" 버튼을 눌렀을 때 실행할 이벤트
        self.faveButton.rx.controlEvent(.touchUpInside).asObservable()
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                // Realm DB에 즐겨찾기 장소 저장 또는 삭제하기
                if self.faveButton.isSelected {
                    self.viewModel.addMyPlaceData()
                } else {
                    self.viewModel.removeMyPlaceData()
                    //self.animateDismissView()
                }
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
        return self.viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "PlaceInfoCell", for: indexPath) as? PlaceInfoTableViewCell else { fatalError() }
        
        // 데이터 보내기 (3): PlaceVM -> PlaceVC(바인딩)
        self.viewModel.titleInfo
            .asDriver(onErrorJustReturn: ["알수없음"])
            .compactMap { $0[indexPath.row ] }
            .drive(cell.titleLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.subtitleInfo
            .asDriver(onErrorJustReturn: ["알수없음"])
            .compactMap { $0[indexPath.row ] }
            .drive(cell.descriptionLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        // 자연휴양림의 경우 label을 클릭했을 때 홈페이지 연결 기능 적용
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
