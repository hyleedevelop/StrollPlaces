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

final class MapViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            self.mapView.region = .init(center: region.center,
                                        latitudinalMeters: region.delta,
                                        longitudinalMeters: region.delta)
        }
    }
    
    //MARK: - property
    
    // 인스턴스
    internal var viewModel: MapViewModel!
    internal let locationManager = CLLocationManager()
    internal lazy var clusterManager: ClusterManager = {
        let manager = ClusterManager()
        manager.delegate = self
        manager.maxZoomLevel = 17
        manager.minCountForClustering = 3
        manager.clusterPosition = .nearCenter
        return manager
    }()
    
    // Rx 관련
    let titleSubject = PublishSubject<String>()
    let annotationColorSubject = PublishSubject<UIColor>()
//    internal let placeNameSubject = PublishSubject<String>()
//    var placeName: Observable<String> {
//        return placeNameSubject.asObservable()
//    }
    let stringRelay = BehaviorRelay<String>(value: "정보없음")
    
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
    
    // 사용자의 현재 위치를 받아오고, 이를 중심으로 regionRadius 반경만큼의 영역을 보여주기
    var currentLocation: CLLocation {
        let latitude = ((locationManager.location?.coordinate.latitude) ?? K.Map.defaultLatitude) as Double
        let longitude = ((locationManager.location?.coordinate.longitude) ?? K.Map.defaultLongitude) as Double
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // 지도 및 CSV데이터 관련
    var dataArray = [PublicData]()
    var annotationArray = [Annotation]()
    let region = (
        center: CLLocationCoordinate2D(latitude: K.Map.southKoreaCenterLatitude,
                                       longitude: K.Map.southKoreaCenterLongitude),
        delta: 2.0
    )
    var annotationColor: UIColor!
    
    // annotation의 지도 표시 여부
    var isAnnotationMarked = [Bool](repeating: false, count: InfoType.allCases.count)
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserLocation()
        setupMapView()
        setupCollectionView()
        setupMapControlButton()
        
        moveToCurrentLocation()
        addAnnotations(with: .park)
    }
    
    //MARK: - method
    
    // 지도 관련 설정
    private func setupMapView() {
        // 델리게이트 설정
        self.mapView.delegate = self
        
        // 제스처 관련 설정
        self.mapView.isZoomEnabled = true
        self.mapView.isRotateEnabled = true
        self.mapView.isScrollEnabled = true
        self.mapView.isPitchEnabled = false
        self.mapView.isUserInteractionEnabled = true
        
        // 사용자 위치 표시 관련 설정
        self.mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(.follow, animated: true)
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.delegate = self
        
        // 컴퍼스 관련 설정
        self.mapView.showsCompass = false
        
        // 카메라 줌아웃 제한 설정
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 2000.km)
        self.mapView.setCameraZoomRange(zoomRange, animated: true)
        
        // 지도 영역 제한 설정
        let region = MKCoordinateRegion(center: K.Map.southKoreaCenterLocation.coordinate,
                                        latitudinalMeters: 750.km,
                                        longitudinalMeters: 750.km)
        self.mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: false)
    }
    
    // CollectionView 설정
    private func setupCollectionView() {
        self.mapView.addSubview(self.themeButtonCollectionView)
        
        self.themeButtonCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(5)
            $0.left.right.equalTo(self.mapView.safeAreaLayoutGuide)
            $0.height.equalTo(K.ThemeCV.cellHeight)
        }
        
        self.themeButtonCollectionView.delegate = self
        self.themeButtonCollectionView.dataSource = self
        
        self.viewModel = MapViewModel()  // 셀의 초기화가 진행되는 시점
    }
    
    // map controll button 설정
    private func setupMapControlButton() {
        // 각 버튼 및 컴퍼스의 UI 설정
        let compassButton = MKCompassButton(mapView: self.mapView)
        [zoomInButton, zoomOutButton, currentLocationButton, compassButton].forEach {
            $0.layer.cornerRadius = $0.frame.height / 2.0
            $0.layer.masksToBounds = false
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowRadius = 1
            $0.layer.shadowOffset = CGSize(width: 0, height: 1)
            $0.layer.shadowOpacity = 0.3
        }
        
        self.view.addSubview(compassButton)
        compassButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-30)
            $0.right.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
        }
        
        // "줌인" 버튼을 눌렀을 때
        self.zoomInButton.rx.controlEvent(.touchUpInside).asObservable()
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.mapView.zoomLevel += 1
            })
            .disposed(by: rx.disposeBag)
        
        // "줌아웃" 버튼을 눌렀을 때
        self.zoomOutButton.rx.controlEvent(.touchUpInside).asObservable()
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.mapView.zoomLevel -= 2
            })
            .disposed(by: rx.disposeBag)
        
        // "현재위치로 이동하기" 버튼을 눌렀을 때
        self.currentLocationButton.rx.controlEvent(.touchUpInside).asObservable()
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.mapView.centerToLocation(
                    location: self.currentLocation,
                    deltaLat: 1.0.km,
                    deltaLon: 1.0.km
                )
            })
            .disposed(by: rx.disposeBag)
    }
    
    // 현재 사용자의 위치로 지도 이동
    internal func moveToCurrentLocation() {
        let latitude = ((locationManager.location?.coordinate.latitude) ?? K.Map.defaultLatitude) as Double
        let longitude = ((locationManager.location?.coordinate.longitude) ?? K.Map.defaultLongitude) as Double
        self.mapView.centerToLocation(
            location: CLLocation(latitude: latitude, longitude: longitude),
            deltaLat: 1.0.km,
            deltaLon: 1.0.km
        )
    }
    
    // annotation cluster 설정
    internal func addAnnotations(with type: InfoType) {
        // 앱을 최초로 실행할 때(dataArray가 비어있을 떄)만 데이터 불러오기
        if dataArray.count == 0 {
            dataArray = viewModel.getPublicData()
        }
        
        self.clusterManager.remove(annotationArray)
        annotationArray.removeAll()
        annotationArray = (0..<self.dataArray.count).map { index in
            let annotation = Annotation()
            if let lat = self.dataArray[index].lat,
               let lon = self.dataArray[index].lon {
                
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                //annotation.title = self.dataArray[index].name
                annotation.title = "\(index)"
                annotation.subtitle = "\(self.dataArray[index].infoType.rawValue)"
                annotation.index = index
            }
            return annotation
        }
        
        // 선택한 테마에 해당하는 annotation만 추가하기
        self.clusterManager.add(annotationArray.filter { $0.subtitle == "\(type.rawValue)" })
        self.clusterManager.reload(mapView: self.mapView)
        isAnnotationMarked[type.rawValue] = true
    }
    
    internal func removeAnnotations() {
        self.clusterManager.remove(annotationArray)
        self.clusterManager.reload(mapView: self.mapView)
        self.annotationArray.removeAll()
    }

}

class MeAnnotation: Annotation {}
