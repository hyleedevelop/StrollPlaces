//
//  MapViewController.swift
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
import MapKit
import Cluster
import ViewAnimator
import Lottie
import Hero
import RealmSwift
import Floaty
import NVActivityIndicatorView

final class MapViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - UI property
    
    // collection view
    internal lazy var themeButtonCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
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
    
    // 컴퍼스 버튼
    private lazy var compassButton: MKCompassButton = {
        let cb = MKCompassButton(mapView: self.mapView)
        cb.layer.cornerRadius = cb.frame.height / 2.0
        cb.layer.masksToBounds = false
        cb.layer.shadowColor = UIColor.black.cgColor
        cb.layer.shadowRadius = 1
        cb.layer.shadowOffset = CGSize(width: 0, height: 1)
        cb.layer.shadowOpacity = 0.3
        return cb
    }()
    
    // 메뉴 버튼
    private lazy var menuButton: Floaty = {
        let button = Floaty()
        button.plusColor = UIColor.white
        button.buttonColor = K.Color.mainColor
        button.itemImageColor = UIColor.black
        button.itemButtonColor = UIColor.white
        button.openAnimationType = .pop
        button.animationSpeed = 0.05
        return button
    }()
    
    // 위치 추적모드 해제 버튼
    internal lazy var trackingStopButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("위치 추적모드 해제하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        button.layer.cornerRadius = 22.5
        button.backgroundColor = UIColor.black
        button.alpha = 0.5
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.cgColor
        button.isHidden = true
        return button
    }()
    
    // 로딩 아이콘
    internal let activityIndicator: NVActivityIndicatorView = {
        let activityIndicator = NVActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: 40, height: 40),
            type: .ballPulseSync,
            color: K.Color.themeRed,
            padding: .zero)
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    
    //MARK: - normal property
    
    internal let viewModel = MapViewModel()
    
    internal lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        manager.delegate = self
        return manager
    }()
    
    internal lazy var clusterManager: ClusterManager = {
        let manager = ClusterManager()
        manager.delegate = self
        manager.maxZoomLevel = 17
        manager.minCountForClustering = 3
        manager.clusterPosition = .nearCenter
        return manager
    }()
    
    // 사용자의 현재 위치를 받아오고, 이를 중심으로 regionRadius 반경만큼의 영역을 보여주기
    internal var currentLocation: CLLocation {
        let latitude = ((locationManager.location?.coordinate.latitude) ?? K.Map.defaultLatitude) as Double
        let longitude = ((locationManager.location?.coordinate.longitude) ?? K.Map.defaultLongitude) as Double
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    internal var isUserTrackingModeOn: Bool = false
    
    // 지도 및 CSV데이터 관련
    internal var currentPinNumber: Int = 0
    internal var annotationArray = [Annotation]()
    
    // annotation의 지도 표시 여부
    internal var isAnnotationMarked = [Bool](repeating: false, count: InfoType.allCases.count)
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.getLocationUsagePermission()
        }
        
        self.setupNavigationBar()
        self.setupMapView()
        self.setupCollectionView()
        self.setupMapControlButton()
        self.setupTrackingStopButton()
        self.setupActivityIndicator()
        
        MapService.shared.moveToCurrentLocation(
            manager: self.locationManager, mapView: self.mapView
        )
        self.addAnnotationsOnTheMapView(with: .park)
        
        self.setupNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.locationManager.startUpdatingLocation()
        
        self.view.addSubview(self.menuButton)
        self.menuButton.snp.makeConstraints {
            $0.right.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-40)
            $0.width.height.equalTo(40)
        }
        
        self.mapView.mapType = MKMapType(rawValue: UInt(self.viewModel.mapType))!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation()
        
        self.menuButton.removeFromSuperview()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        self.navigationController?.applyDefaultSettings(hideBar: true)
    }
    
    // 지도 관련 설정
    private func setupMapView() {
        self.mapView.delegate = self
        self.mapView.applyDefaultSettings(
            viewController: self, trackingMode: .follow, showsUserLocation: true
        )
        self.mapView.mapType = MKMapType(rawValue: UInt(self.viewModel.mapType))!
        
        self.locationManager.startUpdatingLocation()
        
        // 카메라 줌아웃 제한 설정
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 2000.km)
        self.mapView.setCameraZoomRange(zoomRange, animated: true)
        
        // 기본 지도 표시 범위 = 500 m
        if self.viewModel.mapRadius == 0.0 {
            self.viewModel.mapRadius = 0.5
            self.mapView.centerToLocation(
                location: self.currentLocation,
                deltaLat: 0.5.km,
                deltaLon: 0.5.km
            )
        }
        
        // Tap Gesture 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.mapViewTapped))
        self.mapView.addGestureRecognizer(tapGesture)
    }
    
    // CollectionView 설정
    private func setupCollectionView() {
        self.view.addSubview(self.themeButtonCollectionView)
        
        self.themeButtonCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(5)
            $0.left.right.equalTo(self.mapView.safeAreaLayoutGuide)
            $0.height.equalTo(K.ThemeCV.cellHeight)
        }
        
        self.themeButtonCollectionView.delegate = self
        self.themeButtonCollectionView.dataSource = self
        
        // 초기화 시 선택되어 있을 셀(공원) 지정하기
        self.themeButtonCollectionView.selectItem(
            at: NSIndexPath(item: 0, section: 0) as IndexPath,
            animated: false,
            scrollPosition: .centeredHorizontally
        )
    }
    
    // map controll button 설정
    private func setupMapControlButton() {
        // 지도 컨트롤 관련 버튼 설정
        self.menuButton.addItem(
            "위치 추적모드", icon: UIImage(named: "icons8-walk-64")
        ) { [weak self] _ in
            guard let self = self else { return }
            self.isUserTrackingModeOn = true
            self.trackingStopButton.isHidden = false
        }
        self.menuButton.addItem(
            "현재위치로 이동", icon: UIImage(named: "icons8-my-location-100")
        ) { [weak self] _ in
            guard let self = self else { return }
            self.mapView.centerToLocation(
                location: self.currentLocation,
                deltaLat: self.viewModel.mapRadius,
                deltaLon: self.viewModel.mapRadius
            )
        }
        self.menuButton.addItem(
            "축소", icon: UIImage(systemName: "minus.magnifyingglass")
        ) { [weak self] _ in
            guard let self = self else { return }
            self.mapView.zoomLevel -= 2
        }
        self.menuButton.addItem(
            "확대", icon: UIImage(systemName: "plus.magnifyingglass")
        ) { [weak self] _ in
            guard let self = self else { return }
            self.mapView.zoomLevel += 1
        }
        
        self.view.addSubview(self.compassButton)
        self.compassButton.snp.makeConstraints {
            $0.left.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-30)
        }
    }
    
    // 위치 추적모드 표시 버튼 설정
    internal func setupTrackingStopButton() {
        self.view.addSubview(self.trackingStopButton)
        self.trackingStopButton.snp.makeConstraints {
            $0.width.equalTo(180)
            $0.height.equalTo(45)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-30)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.trackingStopButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.isUserTrackingModeOn = false
                self.trackingStopButton.isHidden = true
            })
            .disposed(by: rx.disposeBag)
    }
    
    // activity indicator 설정
    private func setupActivityIndicator() {
        self.view.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    // Notification을 받았을 때 수행할 내용 설정
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.setupMapRadius),
            name: Notification.Name(K.UserDefaults.mapRadius), object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.removeMarkedAnnotation),
            name: Notification.Name("removeMarkedPin"), object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.removeAnnotations),
            name: Notification.Name("reloadMap"), object: nil
        )
    }

    @objc private func setupMapRadius() {
        self.mapView.centerToLocation(
            location: self.currentLocation,
            deltaLat: self.viewModel.mapRadius,
            deltaLon: self.viewModel.mapRadius
        )
    }
    
    @objc private func mapViewTapped() {
        // 기존에 경로를 표시하고 있었다면 제거
        if !self.mapView.overlays.isEmpty {
            self.mapView.removeOverlays(self.mapView.overlays)
            MapService.shared.isRouteLineDrawn.onNext(false)
        }
    }
    
    //MARK: - 지도 위 annotation 추가/제거 관련
    
    // 지도 위에 annotation 추가하기
    internal func addAnnotationsOnTheMapView(with type: InfoType) {
        // annotation 배열 비우기
        self.clusterManager.remove(self.annotationArray)
        self.annotationArray.removeAll()
        
        // 모든 장소에 대해 annotation 생성 후 배열에 담기
        self.annotationArray = self.createAnnotations(with: type)

        // 선택한 테마에 해당하는 annotation만 추가하기
        if type == .marked {
            self.clusterManager.add(self.annotationArray.filter { $0.marked == true })
        } else {
            self.clusterManager.add(self.annotationArray.filter { $0.subtitle == "\(type.rawValue)" })
        }
        self.clusterManager.reload(mapView: self.mapView)
        self.isAnnotationMarked[type.rawValue] = true
    }
    
    // publicData를 이용해 annotation 생성하기
    private func createAnnotations(with type: InfoType) -> [Annotation] {
        return self.viewModel.publicData.enumerated().compactMap { index, data in
            guard let lat = data.lat, let lon = data.lon else { return nil }
            
            let annotation = Annotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            annotation.title = data.name
            annotation.subtitle = "\(data.infoType.rawValue)"
            annotation.index = index
            annotation.marked = false
            
            if type == .marked {
                let markedAnnotations = self.viewModel.myPlaceData.filter { $0.pinNumber == index }
                annotation.marked = !markedAnnotations.isEmpty
            }
            
            return annotation
        }
    }
    
    // 즐겨찾기에 등록되어있던 annotation 제거하기
    @objc private func removeMarkedAnnotation() {
        if self.themeButtonCollectionView.indexPathsForSelectedItems?.first?.row == 3 {
            self.clusterManager.remove(self.annotationArray[self.currentPinNumber])
            self.clusterManager.reload(mapView: self.mapView)
        }
    }
    
    // annotation 전부 제거하기
    @objc internal func removeAnnotations() {
        if self.themeButtonCollectionView.indexPathsForSelectedItems?.first?.row == 3 {
            self.clusterManager.remove(self.annotationArray)
            self.clusterManager.reload(mapView: self.mapView)
            self.annotationArray.removeAll()
        }
    }
    
}

class MeAnnotation: Annotation {}
