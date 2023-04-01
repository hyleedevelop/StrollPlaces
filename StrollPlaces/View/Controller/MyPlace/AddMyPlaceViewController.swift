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
    @IBOutlet weak var nameField: SkyFloatingLabelTextField!
    @IBOutlet weak var introField: SkyFloatingLabelTextField!
    @IBOutlet weak var featureField: SkyFloatingLabelTextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //MARK: - normal property
    
    private let userDefaults = UserDefaults.standard
    private var locationManager: CLLocationManager!
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 스위치의 값을 UserDefaults에 저장
        self.userDefaults.set(false, forKey: "testSwitchValue")
        
        setupNavigationBar()
        setupLocationManager()
        
        setupBackView()
        setupTextField()
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
        
        self.routeInfoBackView.backgroundColor = K.Color.mainColorLight
        self.routeInfoBackView.layer.cornerRadius = 0
        self.routeInfoBackView.clipsToBounds = true
        self.routeInfoBackView.layer.masksToBounds = false
        self.routeInfoBackView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.routeInfoBackView.layer.shadowColor = UIColor.black.cgColor
        self.routeInfoBackView.layer.shadowRadius = 3
        self.routeInfoBackView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.routeInfoBackView.layer.shadowOpacity = 0.3
        self.routeInfoBackView.layer.borderColor = K.Color.mainColor.cgColor
        self.routeInfoBackView.layer.borderWidth = 0
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
                // 나만의 산책길 탭 메인화면으로 돌아가기
                self.navigationController?.popToRootViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        // (2) 취소 버튼
        self.cancelButton.layer.cornerRadius = self.saveButton.frame.height / 2.0
        self.cancelButton.clipsToBounds = true
        
        self.cancelButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                // 이전화면(경로만들기)로 돌아가기
                self.dismiss(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
}

//MARK: - extension for CLLocationManagerDelegate

extension AddMyPlaceViewController: CLLocationManagerDelegate {
    
    
    
}
