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
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: -3)
        view.layer.shadowRadius = 3
        return view
    }()
    
    private let iconBackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 13
        view.clipsToBounds = true
        return view
    }()
    
    private let iconImage: UIImageView = {
        let image = UIImageView()
        image.tintColor = UIColor.black
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
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
        sv.spacing = 10
        sv.alignment = .fill
        sv.distribution = .fillProportionally
        return sv
    }()
    
    public let navigateButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = K.Color.mainColor
        button.setTitle(K.DetailView.navigateButtonName, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 22.5
        button.clipsToBounds = true
        return button
    }()
    
    public let bookmarkButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = K.Color.themeYellow
        button.setTitle(K.DetailView.bookmarkButtonName, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 22.5
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [navigateButton, bookmarkButton])
        sv.axis = .horizontal
        sv.spacing = 20
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
    
    internal let maxDimmedAlpha: CGFloat = 0.15  // 값이 0이면 투명 -> 탭 해도 dismiss가 일어나지 않음
    //internal let defaultHeight: CGFloat = 150 + (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)

    private let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    
    internal let dismissibleHeight: CGFloat = 135
    internal lazy var defaultHeight: CGFloat = 155 + (scene?.windows.first?.safeAreaInsets.bottom ?? 0)
    internal lazy var currentContainerHeight: CGFloat = 155 + (scene?.windows.first?.safeAreaInsets.bottom ?? 0)
    internal let maximumContainerHeight: CGFloat = 500
    internal var maximumContainerHeightByButton: CGFloat = 500
    
    // Dynamic container constraint
    //internal var containerViewHeightRelay = BehaviorRelay<CGFloat>(value: 190)
    internal var containerViewHeightConstraint: NSLayoutConstraint?
    internal var containerViewBottomConstraint: NSLayoutConstraint?
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        setupTopUI()
        setupMiddleUI()
        setupBottomUI()
        
        setupConstraints()
        
        setupTapGesture()
        setupPanGesture()
        
        setupBinding()
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
        // icon image
        self.containerView.addSubview(self.iconBackView)
        self.iconBackView.addSubview(self.iconImage)
        self.iconBackView.snp.makeConstraints {
            $0.top.equalTo(self.containerView.safeAreaLayoutGuide).offset(20)
            $0.left.equalTo(self.containerView.safeAreaLayoutGuide).offset(20)
            $0.height.equalTo(26)
            $0.width.equalTo(26)
        }
        self.iconImage.snp.makeConstraints {
            $0.top.left.right.bottom.equalTo(self.iconBackView)
        }
        
        // disclosure button
        self.containerView.addSubview(self.disclosureButton)
        self.disclosureButton.snp.makeConstraints {
            $0.top.equalTo(self.containerView.safeAreaLayoutGuide).offset(20)
            $0.width.height.equalTo(30)
            $0.right.equalTo(self.containerView.safeAreaLayoutGuide).offset(-20)
        }
        
        // name label
        self.containerView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints {
            $0.top.equalTo(self.containerView.safeAreaLayoutGuide).offset(20)
            $0.left.equalTo(self.iconBackView.snp.right).offset(10)
            $0.right.equalTo(self.disclosureButton.snp_leftMargin).offset(-20)
            $0.height.equalTo(26)
        }
    }
    
    private func setupMiddleUI() {
        self.containerView.addSubview(self.labelStackView)
        self.labelStackView.snp.makeConstraints {
            $0.top.equalTo(self.iconBackView.snp.bottom).offset(15)
            $0.left.equalTo(self.containerView.safeAreaLayoutGuide).offset(20)
            $0.height.equalTo(18)
            $0.width.equalTo(260)
        }
        
        self.distanceLabel.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        
        self.expectedTimeLabel.snp.makeConstraints {
            $0.width.equalTo(150)
        }
    }
    
    private func setupBottomUI() {
        self.containerView.addSubview(self.buttonStackView)
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(self.labelStackView.snp.bottom).offset(15)
            $0.left.equalTo(self.containerView.safeAreaLayoutGuide).offset(20)
            $0.right.equalTo(self.containerView.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(45)
        }
    }
    
    internal func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PlaceInfoTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "PlaceInfoCell")
        
        containerView.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.navigateButton.snp_bottomMargin).offset(25)
            $0.left.right.equalTo(self.containerView.safeAreaLayoutGuide)
            //$0.height.equalTo(300)
            $0.bottom.equalTo(self.containerView.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    private func setupBinding() {
        let placeType = self.viewModel.getPlaceType().asDriver(onErrorJustReturn: .marked)
        let placeName = self.viewModel.getPlaceInfo().asDriver(onErrorJustReturn: ["알수없음"])
        let distance = self.viewModel.estimatedDistance.asDriver(onErrorJustReturn: "알수없음")
        let time = self.viewModel.estimatedTime.asDriver(onErrorJustReturn: "알수없음")
        
        // 장소 유형
        placeType.map { type -> UIImage in
            switch type {
            case .marked:
                return UIImage(systemName: "star.fill") ?? UIImage()
            case .park:
                return UIImage(systemName: "tree.fill") ?? UIImage()
            case .strollWay:
                return UIImage(systemName: "road.lanes") ?? UIImage()
            case .recreationForest:
                return UIImage(systemName: "mountain.2.fill") ?? UIImage()
            case .tourSpot:
                return UIImage(systemName: "hand.thumbsup.fill") ?? UIImage()
            }
            //return UIImage(systemName: "star") ?? UIImage()
        }
        .map { $0.withAlignmentRectInsets(
            UIEdgeInsets(top: -4, left: -4, bottom: -4, right: -4)
        )}
        .drive(iconImage.rx.image)
        .disposed(by: rx.disposeBag)
        
        // 장소명
        placeName.map { $0[0] }
            .drive(nameLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        // 거리
        distance.drive(distanceLabel.rx.text)
            .disposed(by: rx.disposeBag)

        // 소요시간
        time.drive(expectedTimeLabel.rx.text)
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
        self.bookmarkButton.rx.controlEvent(.touchUpInside).asObservable()
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .subscribe(
                onNext: {
                    let indicatorView = SPIndicatorView(title: "등록 완료", preset: .done)
                    indicatorView.present(duration: 2.0, haptic: .success)
                }, onError: { _ in
                    let indicatorView = SPIndicatorView(title: "등록 실패", preset: .error)
                    indicatorView.present(duration: 2.0, haptic: .error)
                })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - indirectly called method
    
}

//MARK: - extension for UITableViewDelegate, UITableViewDataSource

extension PlaceInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.getTitleInfo()
        var numberOfRows = 0
        self.viewModel.numberOfItems
            .subscribe { num in
                numberOfRows = num
            }
            .disposed(by: rx.disposeBag)
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "PlaceInfoCell", for: indexPath) as? PlaceInfoTableViewCell else { fatalError() }
        
        // 데이터 보내기 (3): PlaceVM -> PlaceVC(바인딩)
        self.viewModel.getTitleInfo()
            .asDriver(onErrorJustReturn: ["알수없음"])
            .map { $0[indexPath.row ] }
            .drive(cell.titleLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.getPlaceInfo()
            .asDriver(onErrorJustReturn: ["알수없음"])
            .map { $0[indexPath.row ] }
            .drive(cell.descriptionLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        return cell
    }
    
}
