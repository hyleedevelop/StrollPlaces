//
//  MapViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import CoreLocation
import MapKit
import SnapKit
import RxSwift
import RxCocoa

class MapViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - property
    
    // 인스턴스 관련
    private let mapViewModel = MapViewModel()
    private var locationManager: CLLocationManager!
    //private var clusterManager: MKClusterAnnotation!
    
    // Rx 관련
    //private let bag = DisposeBag()
    
    // UI 관련
    private lazy var testButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("버튼", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 20
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1.0
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }()

    // collection view
    private lazy var themeButtonCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 120, height: K.ThemeCV.cellHeight)
        flowLayout.minimumInteritemSpacing = K.ThemeCV.spacingWidth
        flowLayout.minimumLineSpacing = K.ThemeCV.spacingHeight
        let cv = UICollectionView(frame: CGRect(), collectionViewLayout: flowLayout)
        cv.isScrollEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.collectionViewLayout = flowLayout
        cv.register(UINib(nibName: K.ThemeCV.cellName, bundle: nil), forCellWithReuseIdentifier: K.ThemeCV.cellName)
        cv.backgroundColor = UIColor.clear
        return cv
    }()
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        mapViewModel.setupRealmData()
        
        setupUserLocation()
        setupMapView()
//        addMarker()
        
        //setupButton()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.locationManager.stopUpdatingLocation()
        self.locationManager.stopUpdatingHeading()
    }
    
    //MARK: - method
    
    // 지도 관련 설정
    private func setupMapView() {
        // 기본 설정
        self.mapView.isZoomEnabled = true
        self.mapView.isRotateEnabled = true
        self.mapView.isScrollEnabled = true
        self.mapView.isPitchEnabled = true
        self.mapView.isUserInteractionEnabled = true
        self.mapView.showsCompass = true
        self.mapView.centerToLocation(location: K.Map.initialLocation, regionRadius: 1000)  // 초기위치를 중심으로 반경 1 km 까지 표시
        
        // 카메라 영역 제한 설정
//        let region = MKCoordinateRegion(center: K.Map.southKoreaCenterLocation.coordinate,
//                                        latitudinalMeters: 0,
//                                        longitudinalMeters: 0)
//        self.mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region),
//                                       animated: true)
        
        // 카메라 줌 제한 설정
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 1400.km)
        self.mapView.setCameraZoomRange(zoomRange, animated: true)
    }
    
    private func setupButton() {
//        self.mapView.addSubview(testButton)
//
//        testButton.snp.makeConstraints {
//            $0.left.equalToSuperview().offset(20)
//            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(50)
//            $0.width.equalTo(80)
//            $0.height.equalTo(30)
//        }
    }
    
    private func setupCollectionView() {
        self.mapView.addSubview(self.themeButtonCollectionView)
        
        self.themeButtonCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            $0.left.right.equalTo(self.mapView.safeAreaLayoutGuide)
            $0.height.equalTo(35)
        }
        
        self.themeButtonCollectionView.delegate = self
        self.themeButtonCollectionView.dataSource = self
    }
    
    
    //MARK: - @objc method
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender == testButton {
            print("버튼을 클릭했습니다.")
        }
    }
        
}

//MARK: - extension for CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    // 1. 사용자 위치 관련 설정
    private func setupUserLocation() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.getLocationUsagePermission()
    }
    
    // 2. 위치 추적 권한 요청 실행
    private func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // 3. 위치 추적 권한 요청 결과에 따른 처리
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("위치 추적 권한 허용됨")
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
        case .restricted, .notDetermined:
            print("위치 추적 권한 미설정")
        case .denied:
            print("위치 추적 권한 거부됨")
        default:
            break
        }
    }
    
}

//MARK: - extension for UICollectionViewDataSource, UICollectionViewDelegate

extension MapViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.ThemeCV.cellName, for: indexPath)
                as? ThemeCollectionViewCell else { return UICollectionViewCell() }
//        let cellViewModel = cellDataSource[indexPath.row]
//
//        cell.updateCell(viewModel: cellViewModel)
        
        switch indexPath.row {
        case 0:
            cell.themeLabel.layer.borderColor = UIColor.black.cgColor
            cell.themeLabel.layer.borderWidth = 1.5
            cell.themeLabel.text = "공원"
        case 1:
//            cell.themeButton.setTitle("산책로", for: .normal)
            cell.themeLabel.text = "산책로"
        case 2:
//            cell.themeButton.setTitle("지역명소", for: .normal)
            cell.themeLabel.text = "지역명소"
        case 3:
            cell.themeLabel.text = "화장실"
        default:
            print("nothing...")
        }
        
        cell.themeLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.ThemeCV.cellName, for: indexPath)
                as? ThemeCollectionViewCell else { return }
        
        cell.themeLabel.layer.borderColor = UIColor.black.cgColor
        cell.themeLabel.layer.borderWidth = 1.5
        print(#function)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.ThemeCV.cellName, for: indexPath)
                as? ThemeCollectionViewCell else { return }
        
        cell.themeLabel.layer.borderColor = UIColor.lightGray.cgColor
        cell.themeLabel.layer.borderWidth = 0.5
        print(#function)
    }
    
}
