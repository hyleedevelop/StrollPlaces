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
    
    internal var trackData = TrackData()
    internal var trackPoint = TrackPoint()
    internal var track: Results<TrackData>!
    internal var point: Results<TrackPoint>!
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupRealm()
        
        // 스위치의 값을 UserDefaults에 저장
        self.userDefaults.set(false, forKey: "testSwitchValue")
        
        setupNavigationBar()
        setupLocationManager()
        
        setupBackView()
        setupTextField()
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }

    //MARK: - directly called method
    
    // Realm DB 설정
    private func setupRealm() {
//        self.track = RealmService.shared.realm.objects(TrackData.self)
//        guard let latestData = self.track?.last else { return }
//        print(latestData.date)
//        print(latestData.points.last?.latitude as? Double,
//              latestData.points.last?.longitude as? Double)
//
//        calculateDistanceBetweenTrackPoints()
    }
    
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
            // Realm DB에 저장했던 경로 삭제하기
            self.track = RealmService.shared.realm.objects(TrackData.self)
            self.point = RealmService.shared.realm.objects(TrackPoint.self)
            guard let latestTrackData = self.track?.last else { return }
            //guard let latestPointData = self.point else { return }
            RealmService.shared.delete(latestTrackData)
            
            
            // 이전화면(경로만들기)로 돌아가기
            self.navigationController?.popToRootViewController(animated: true)
            //self.dismiss(animated: true)
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
