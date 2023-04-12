//
//  AddMyPlaceViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/28.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import CoreLocation
import MapKit
import RealmSwift
import SkyFloatingLabelTextField

class AddMyPlaceViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var routeInfoBackView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var endLocationLabel: UILabel!
    
    @IBOutlet weak var nameField: SkyFloatingLabelTextField!
    @IBOutlet weak var explanationField: SkyFloatingLabelTextField!
    @IBOutlet weak var featureField: SkyFloatingLabelTextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //MARK: - normal property
    
    private let viewModel = AddMyPlaceViewModel()
    private let userDefaults = UserDefaults.standard
    private var locationManager: CLLocationManager!
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 스위치의 값을 UserDefaults에 저장
        self.userDefaults.set(true, forKey: "testSwitchValue")
        
        // Realm DB에서 데이터 가져오기
        self.viewModel.getTrackDataFromRealmDB()
        
        setupNavigationBar()
        setupLocationManager()
        setupBackView()
        setupLabel()
        setupTextField()
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
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
    
    private func setupLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    // 경로정보 영역의 Back View 설정
    private func setupBackView() {
        self.mapView.layer.cornerRadius = 5
        self.mapView.clipsToBounds = true
        
        self.routeInfoBackView.backgroundColor = K.Color.themeWhite
        self.routeInfoBackView.layer.cornerRadius = 20
        self.routeInfoBackView.clipsToBounds = true
        self.routeInfoBackView.layer.masksToBounds = false
        //self.routeInfoBackView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.routeInfoBackView.layer.shadowColor = UIColor.black.cgColor
        self.routeInfoBackView.layer.shadowRadius = 3
        self.routeInfoBackView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.routeInfoBackView.layer.shadowOpacity = 0.3
        self.routeInfoBackView.layer.borderColor = K.Color.themeBlack.cgColor
        self.routeInfoBackView.layer.borderWidth = 1
    }
    
    // Realm DB 설정
    private func setupLabel() {
        self.viewModel.dateRelay.asDriver(onErrorJustReturn: "dateRealy error")
            .drive(self.dateLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.timeRelay.asDriver(onErrorJustReturn: "timeRealy error")
            .drive(self.timeLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.distanceRelay.asDriver(onErrorJustReturn: "distanceRelay error")
            .drive(self.distanceLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.firstLocationRelay.asDriver(onErrorJustReturn: "firstLocationRelay error")
            .drive(self.startLocationLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.lastLocationRelay.asDriver(onErrorJustReturn: "lastLocationRelay error")
            .drive(self.endLocationLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    // TextField 및 TextView 설정
    private func setupTextField() {
        self.nameField.errorColor = UIColor.red
        self.nameField.returnKeyType = .default
    }
    
    private func setupButton() {
        // (1) 저장 버튼
        self.saveButton.layer.cornerRadius = self.saveButton.frame.height / 2.0
        self.saveButton.clipsToBounds = true
        
        self.saveButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                if self.nameField.text != nil {
                    self.viewModel.updateTrackData(
                        name: self.nameField.text!,
                        explanation: self.explanationField.text,
                        feature: self.featureField.text
                    )
                } else {
                    print("산책길 이름을 입력하세요")
                }
                
                // 나만의 산책길 탭 메인화면으로 돌아가기
                self.navigationController?.popToRootViewController(animated: true)
//                self.dismiss(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        // (2) 취소 버튼
        self.cancelButton.layer.cornerRadius = self.saveButton.frame.height / 2.0
        self.cancelButton.clipsToBounds = true
        
        self.cancelButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.showAlertMessageForReturn()
            })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - indirectly called method
    
    private func calculateDistanceBetweenTrackPoints() {
        
    }
    
    private func showAlertMessageForReturn() {
        // 진짜로 취소할 것인지 alert message 보여주고 확인받기
        let alert = UIAlertController(title: "확인",
                                      message: "지금까지 작성한 내용을\n모두 삭제할까요?",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "아니요", style: .default)
        let okAction = UIAlertAction(title: "네", style: .destructive) { _ in
            // Realm DB에 임시로 저장했던 경로 삭제하기
            self.viewModel.clearTemporaryTrackData()
            // 이전화면(경로만들기)로 돌아가기
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        // 메세지 보여주기
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - extension for CLLocationManagerDelegate

extension AddMyPlaceViewController: CLLocationManagerDelegate {
    
    
    
}
