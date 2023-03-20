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
        view.layer.cornerRadius = 0
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: -3)
        view.layer.shadowRadius = 3
        return view
    }()
    
    private let grabber: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.layer.cornerRadius = 1.5
        view.clipsToBounds = true
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let subtitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let detailButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = K.Map.themeColor[0]
        button.setTitle("세부사항 보기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 2
        button.clipsToBounds = true
        return button
    }()
    
    private let navigateButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = K.Map.themeColor[2]
        button.setTitle("길 안내", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 2
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [detailButton, navigateButton])
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
        tv.showsVerticalScrollIndicator = false
        return tv
    }()
    
    //MARK: - normal property
    
    var placeData: PublicData?
    var isDetailActivated = false
    
    // Constants
    internal let maxDimmedAlpha: CGFloat = 0.15  // 값이 0이면 투명 -> 탭 해도 dismiss가 일어나지 않음
    internal let defaultHeight: CGFloat = 190
    internal let dismissibleHeight: CGFloat = 120
    //internal let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 100
    internal let maximumContainerHeight: CGFloat = 500
    internal var currentContainerHeight: CGFloat = 190  // keep current new height, initial is default height
    internal var maximumContainerHeightByButton: CGFloat = 500
    
    // Dynamic container constraint
    internal var containerViewHeightRelay = BehaviorRelay<CGFloat>(value: 190)
    internal var containerViewHeightConstraint: NSLayoutConstraint?
    internal var containerViewBottomConstraint: NSLayoutConstraint?
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLabel()
        setupButton()
        //setupTableView()
        
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
        view.backgroundColor = .clear
        
        // dimmed view
        self.view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints {
            $0.left.right.top.bottom.equalTo(self.view)
        }
                
        // container view
        view.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.left.right.equalTo(self.view)
        }
        
        // grabber
        containerView.addSubview(grabber)
        grabber.snp.makeConstraints {
            $0.top.equalTo(self.containerView.safeAreaLayoutGuide).offset(5)
            $0.height.equalTo(3)
            $0.centerX.equalTo(self.containerView)
            $0.width.equalTo(25)
        }
    }
    
    private func setupLabel() {
        self.containerView.addSubview(self.nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(self.containerView.safeAreaLayoutGuide).offset(30)
            $0.height.equalTo(30)
            $0.left.right.equalTo(self.containerView.safeAreaLayoutGuide).offset(30)
        }

        self.containerView.addSubview(self.subtitle)
        subtitle.snp.makeConstraints {
            $0.top.equalTo(self.nameLabel.snp_bottomMargin).offset(15)
            $0.height.equalTo(20)
            $0.left.right.equalTo(self.containerView.safeAreaLayoutGuide).offset(30)
        }
    }
    
    private func setupButton() {
        self.containerView.addSubview(buttonStackView)
        self.detailButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        self.navigateButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(self.subtitle.snp_bottomMargin).offset(30)
            $0.height.equalTo(45)
            $0.left.equalTo(self.containerView.safeAreaLayoutGuide).offset(30)
            $0.right.equalTo(self.containerView.safeAreaLayoutGuide).offset(-30)
        }
    }
    
    internal func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PlaceInfoTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "PlaceInfoCell")
        
        containerView.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.buttonStackView.snp_bottomMargin).offset(20)
            $0.left.right.equalTo(self.containerView.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.containerView.safeAreaLayoutGuide).offset(10)
        }
        
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 50
    }
    
    private func bindUI() {
        guard let placeData = placeData else { return }
        nameLabel.text = placeData.name
        subtitle.text = placeData.address
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender == detailButton {
            if !isDetailActivated {
                print("세부사항 보기를 실행합니다...")
                animateContainerHeight(maximumContainerHeightByButton)
                self.detailButton.setTitle("세부사항 닫기", for: .normal)
            } else {
                print("세부사항 닫기를 실행합니다...")
                self.detailButton.setTitle("세부사항 보기", for: .normal)
                animateContainerHeight(defaultHeight)
            }
            isDetailActivated.toggle()
        }
        
        if sender == navigateButton {
            print("길 안내를 시작합니다...")
        }
    }
    
}

//MARK: - extension for UITableViewDelegate, UITableViewDataSource

extension PlaceInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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
            
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "유형"
            cell.descriptionLabel.text = self.placeData?.category
        case 1:
            cell.titleLabel.text = "주변시설"
            //cell.descriptionLabel.text = self.placeData?.infra
            cell.descriptionLabel.text = "testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest"
        case 2:
            cell.titleLabel.text = "관리기관명"
            cell.descriptionLabel.text = self.placeData?.organization
        case 3:
            cell.titleLabel.text = "전화번호"
            cell.descriptionLabel.text = self.placeData?.telephoneNumber
        default:
            break
        }
        
        return cell
    }
    
}
