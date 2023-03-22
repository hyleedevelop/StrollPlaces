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
import DropDown

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
        view.layer.cornerRadius = 2
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
        label.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    internal let disclosureButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.backgroundColor = UIColor.systemGray6
        button.tintColor = UIColor.black
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()
    
    public let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    public let expectedTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    public let navigateButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = K.Map.themeColor[0]
        button.setTitle(K.DetailView.navigateButtonName, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 2
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var labelStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [distanceLabel, expectedTimeLabel])
        sv.axis = .horizontal
        sv.spacing = 15
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    internal let tableView: UITableView = {
        let tv = UITableView()
        tv.allowsSelection = false
        tv.separatorStyle = .none
        tv.scrollsToTop = true
        tv.showsVerticalScrollIndicator = false
        tv.alpha = 0.0
        return tv
    }()
    
    //MARK: - normal property
    
    internal var viewModel: PlaceInfoViewModel!
    var isDetailActivated = false
    
    // Constants
    internal let maxDimmedAlpha: CGFloat = 0.15  // 값이 0이면 투명 -> 탭 해도 dismiss가 일어나지 않음
    internal let defaultHeight: CGFloat = 175
    internal let dismissibleHeight: CGFloat = 135
    //internal let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 100
    internal let maximumContainerHeight: CGFloat = 500
    internal var currentContainerHeight: CGFloat = 175  // keep current new height, initial is default height
    internal var maximumContainerHeightByButton: CGFloat = 500
    
    // Dynamic container constraint
    //internal var containerViewHeightRelay = BehaviorRelay<CGFloat>(value: 190)
    internal var containerViewHeightConstraint: NSLayoutConstraint?
    internal var containerViewBottomConstraint: NSLayoutConstraint?
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        setupTopUI()
        setupMiddleUI()
        setupBottomUI()
        
        setupConstraints()
        
        setupTapGesture()
        setupPanGesture()
        
        bindUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    //MARK: - method

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
            $0.left.equalTo(self.containerView.safeAreaLayoutGuide).offset(30)
            $0.height.equalTo(26)
            $0.width.equalTo(26)
        }
        self.iconImage.snp.makeConstraints {
            $0.top.left.right.bottom.equalTo(self.iconBackView)
        }
        
        // disclosure button
        self.containerView.addSubview(self.disclosureButton)
        self.disclosureButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        self.disclosureButton.snp.makeConstraints {
            $0.top.equalTo(self.containerView.safeAreaLayoutGuide).offset(20)
            $0.width.height.equalTo(26)
            $0.right.equalTo(self.containerView.safeAreaLayoutGuide).offset(-30)
        }
        
        // name label
        self.containerView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints {
            $0.top.equalTo(self.containerView.safeAreaLayoutGuide).offset(20)
            $0.left.equalTo(self.iconBackView.snp_rightMargin).offset(20)
            $0.right.equalTo(self.disclosureButton.snp_leftMargin).offset(-10)
            $0.height.equalTo(26)
        }
    }
    
    private func setupMiddleUI() {
        self.containerView.addSubview(self.labelStackView)
        self.labelStackView.snp.makeConstraints {
            $0.top.equalTo(self.iconBackView.snp_bottomMargin).offset(20)
            $0.left.equalTo(self.containerView.safeAreaLayoutGuide).offset(30)
            $0.right.equalTo(self.containerView.safeAreaLayoutGuide).offset(-30)
            $0.height.equalTo(18)
        }
    }
    
    private func setupBottomUI() {
        containerView.addSubview(navigateButton)
        navigateButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        navigateButton.snp.makeConstraints {
            $0.top.equalTo(self.labelStackView.snp_bottomMargin).offset(20)
            $0.left.equalTo(self.containerView.safeAreaLayoutGuide).offset(30)
            $0.right.equalTo(self.containerView.safeAreaLayoutGuide).offset(-30)
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
            $0.top.equalTo(self.navigateButton.snp_bottomMargin).offset(30)
            $0.left.right.equalTo(self.containerView.safeAreaLayoutGuide)
            //$0.height.equalTo(300)
            $0.bottom.equalTo(self.containerView.safeAreaLayoutGuide).offset(10)
        }
        
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 50
    }
    
    private func bindUI() {
        let placeType = self.viewModel.getPlaceType().asDriver(onErrorJustReturn: .marked)
        let placeName = self.viewModel.getPlaceInfo().asDriver(onErrorJustReturn: ["N/A"])
        
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
        }
        .map { $0.withAlignmentRectInsets(
            UIEdgeInsets(top: -4, left: -4, bottom: -4, right: -4)
        )}
        .drive(iconImage.rx.image)
        .disposed(by: rx.disposeBag)
        
        placeName.map { $0[0] }
            .drive(nameLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        distanceLabel.text = "거리: 1.23 km"
        expectedTimeLabel.text = "도착 예상 시간: 7분"
//        routeDriver.map {  }
//            .drive(distanceLabel.rx.text)
//            .disposed(by: rx.disposeBag)
//
//        routeDriver.map {  }
//            .drive(expectedTimeLabel.rx.text)
//            .disposed(by: rx.disposeBag)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender == self.disclosureButton {
            if !isDetailActivated {
                animateContainerHeight(maximumContainerHeightByButton)
                self.disclosureButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.tableView.alpha = 0.0  // TableView 넣기
                }
                self.disclosureButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                animateContainerHeight(defaultHeight)
            }
            isDetailActivated.toggle()
        }
        
        if sender == navigateButton {
            // bottom sheet 닫기
            self.animateDismissView()
        }
    }
    
}

//MARK: - extension for UITableViewDelegate, UITableViewDataSource

extension PlaceInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//        //return 50
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "PlaceInfoCell", for: indexPath) as? PlaceInfoTableViewCell else { fatalError() }
        
        // 데이터 보내기 (3): PlaceVM -> PlaceVC(바인딩)
        self.viewModel.getTitleInfo()
            .asDriver(onErrorJustReturn: ["N/A"])
            .map { $0[indexPath.row + 1] }
            .drive(cell.titleLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.getPlaceInfo()
            .asDriver(onErrorJustReturn: ["N/A"])
            .map { $0[indexPath.row + 1] }
            .drive(cell.descriptionLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        return cell
    }
    
}
