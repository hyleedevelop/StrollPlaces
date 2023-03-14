//
//  MapViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import SnapKit
import CoreLocation
import MapKit
//import Cluster
import RxSwift
import RxCocoa

final class MapViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - property
    
    // 인스턴스
    private var mapViewModel: MapViewModel!
    private var locationManager: CLLocationManager!
    //private var clusterManager: ClusterManager!
    
    // Rx
    private let bag = DisposeBag()
    
    // collection view
    private lazy var themeButtonCollectionView: UICollectionView = {
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
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        mapViewModel.setupRealmData()
        
        setupUserLocation()
        setupMapView()
        setupCollectionView()
        setupMapControlButton()
        
        //setupAnnotationCluster(type: .park)
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
        // 기본 옵션 설정
        self.mapView.isZoomEnabled = true
        self.mapView.isRotateEnabled = true
        self.mapView.isScrollEnabled = true
        self.mapView.isPitchEnabled = true
        self.mapView.isUserInteractionEnabled = true
        self.mapView.showsCompass = true
        
        // 카메라 줌아웃 제한 설정
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 1500.km)
        self.mapView.setCameraZoomRange(zoomRange, animated: true)
        
        // 지도 영역 제한 설정
        let region = MKCoordinateRegion(center: K.Map.southKoreaCenterLocation.coordinate,
                                        latitudinalMeters: 500.km,
                                        longitudinalMeters: 500.km)
        self.mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region),
                                       animated: false)
    
//        self.mapView.addAnnotation(latitude: K.Map.defaultLatitude-0.004,
//                                   longitude: K.Map.defaultLongitude,
//                                   title: "Title",
//                                   subtitle: "Subtitle")
        
        // 앱 최초 실행 시, 남한 전체 영역을 2초간 보여주고, 그 후 사용자의 위치로 2초간 확대하는 애니메이션 실행
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut) {
                    self.mapView.centerToLocation(location: K.Map.southKoreaCenterLocation, regionRadius: 500.km)
                    self.mapView.centerToLocation(location: self.currentLocation, regionRadius: 1000.m)
                }
            }
        }
        
    }
    
    // CollectionView 설정
    private func setupCollectionView() {
        self.mapView.addSubview(self.themeButtonCollectionView)
        
        self.themeButtonCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(1)
            $0.left.right.equalTo(self.mapView.safeAreaLayoutGuide)
            $0.height.equalTo(40)
        }
        
        self.themeButtonCollectionView.delegate = self
        self.themeButtonCollectionView.dataSource = self
        
        let themeCell: [ThemeCellData] = [
            ThemeCellData(icon: UIImage(systemName: "star.fill")!, title: "즐겨찾기"),
            ThemeCellData(icon: UIImage(systemName: "tree.fill")!, title: "공원"),
            ThemeCellData(icon: UIImage(systemName: "road.lanes")!, title: "산책로"),
            ThemeCellData(icon: UIImage(systemName: "triangle.fill")!, title: "지역명소"),
            ThemeCellData(icon: UIImage(systemName: "toilet.fill")!, title: "공중화장실")
        ]
        
        self.mapViewModel = MapViewModel(themeCell)
    }
    
    // map controll button 설정
    private func setupMapControlButton() {
        // "줌인" 버튼을 눌렀을 때
        self.zoomInButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.mapView.zoomLevel += 1
            })
            .disposed(by: self.bag)
        
        // "줌아웃" 버튼을 눌렀을 때
        self.zoomOutButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.mapView.zoomLevel -= 2
            })
            .disposed(by: self.bag)
        
        // "현재위치로 이동하기" 버튼을 눌렀을 때
        self.currentLocationButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.mapView.centerToLocation(location: self.currentLocation, regionRadius: 1000.m)
            })
            .disposed(by: self.bag)
    }
    
    // annotation cluster 설정
    private func setupAnnotationCluster(type: InfoType) {
        self.mapView.delegate = self
        var coordinateArray = [CLLocationCoordinate2D]()
        
        switch type {
            
        case .park:
            let parkArray = mapViewModel.getParkInfo()
            
            DispatchQueue.global().async {
                for index in 1..<parkArray.count-1 {  // for index in 1..<parkArray.count-1
                    if let lat = parkArray[index].lat,
                       let lon = parkArray[index].lon {
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        let annotation = MapItem(coordinate: coordinate)
                        
                        coordinateArray.append(coordinate)
                        self.mapView.addAnnotation(annotation)
                        print(index, coordinate, separator: " / ")
                    }
                }

            }
            
        case .walkingStreet:
            break
            
        case .tourSpot:
            break
            
        }
        
//        for coordinate in coordinateArray {
//
//        }
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

//MARK: - extension for MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let item = annotation as? MapItem {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "mapItem")
                               ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "mapItem")
            
            annotationView.annotation = item
            annotationView.image = UIImage(named: "star.fill")
            annotationView.clusteringIdentifier = "mapItemClustered"
            
            return annotationView
            
        } else if let cluster = annotation as? MKClusterAnnotation {
            let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: "clusterView")
            ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "clusterView")
            
            clusterView.annotation = cluster
            clusterView.image = UIImage(named: "star.fill")
            
            return clusterView
            
        } else {
            return nil
            
        }
    }
    
}

//MARK: - extension for UICollectionViewDataSource, UICollectionViewDelegate

extension MapViewController: UICollectionViewDataSource,
                             UICollectionViewDelegate,
                             UICollectionViewDelegateFlowLayout {
    
    // section의 개수
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // section 내 아이템의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mapViewModel.themeCellViewModel.count
    }
    
    // 각 셀마다 실행할 내용
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.ThemeCV.cellName, for: indexPath)
                as? ThemeCollectionViewCell else { return UICollectionViewCell() }

        // drive 연산자를 이용해 이미지를 바인딩
        self.mapViewModel.cellData(at: indexPath.row).icon.asDriver(onErrorJustReturn: UIImage())
            .drive(cell.themeIcon.rx.image)
            .disposed(by: self.bag)
        
        // drive 연산자를 이용해 텍스트를 바인딩
        self.mapViewModel.cellData(at: indexPath.row).title.asDriver(onErrorJustReturn: "")
            .drive(cell.themeLabel.rx.text)
            .disposed(by: self.bag)
        
        // 텍스트 폰트 설정
        cell.themeLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        
        return cell
    }
    
    // 각 셀의 사이즈 설정
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: Double?
        
        self.mapViewModel.cellData(at: indexPath.row).title.asObservable()
            .map { $0.count }
            .subscribe(onNext: { value in
                width = Double(value) * 15 + 40
            })
            .disposed(by: self.bag)
            
        guard let width = width else {
            fatalError("[ERROR] Unable to get size for collection view cell.")
        }
        
        return CGSize(width: width, height: K.ThemeCV.cellHeight)
    }
    
    // 셀이 선택되었을 때 실행할 내용
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.ThemeCV.cellName, for: indexPath)
                as? ThemeCollectionViewCell else { return }
        
        cell.themeLabel.layer.borderColor = UIColor.black.cgColor
        cell.themeLabel.layer.borderWidth = 1.5
        print(#function, "\(indexPath.row)", separator: ", ")
    }
    
    // 셀이 해제되었을 때 실행할 내용
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.ThemeCV.cellName, for: indexPath)
                as? ThemeCollectionViewCell else { return }
        
        cell.themeLabel.layer.borderColor = UIColor.lightGray.cgColor
        cell.themeLabel.layer.borderWidth = 0.5
        print(#function, "\(indexPath.row)", separator: ", ")
    }
    
}
