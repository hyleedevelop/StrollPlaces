//
//  DetailInfoViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/02.
//

import UIKit
import CoreLocation
import MapKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class DetailInfoViewController: UIViewController {

    //MARK: - IB outlet & action
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelBackView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    //MARK: - normal property
    
    private let viewModel = DetailInfoViewModel()
    private var locationManager: CLLocationManager!
    var cellIndex: Int = 0
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupMapView()
        //self.setupBackView()
        self.setupCloseButton()
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
//        navigationBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        // scrollEdge: 스크롤 하기 전의 NavigationBar
        // standard: 스크롤을 하고 있을 때의 NavigationBar
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isHidden = true
        navigationController?.setNeedsStatusBarAppearanceUpdate()
        navigationController?.modalPresentationStyle = .overFullScreen

        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        
        self.extendedLayoutIncludesOpaqueBars = false
    }

    // MapView 설정
    private func setupMapView() {
        self.mapView.layer.cornerRadius = 5
        self.mapView.clipsToBounds = true
        self.mapView.layer.borderColor = K.Color.themeGray.cgColor
        self.mapView.layer.borderWidth = 0.5
        self.mapView.showsUserLocation = false
        self.mapView.setUserTrackingMode(.none, animated: true)
        self.mapView.isZoomEnabled = true
        self.mapView.delegate = self
        
        // 각 지점들을 기록하고 그 지점들 사이를 선으로 연결
        let points: [CLLocationCoordinate2D] =
        self.viewModel.getTrackPointForPolyline(index: self.cellIndex)
        let routeLine = MKPolyline(coordinates: points, count: points.count)
        
        // 지도에 선 나타내기(addOverlay 시 아래의 rendererFor 함수가 호출됨)
        self.mapView.addOverlay(routeLine)
        
        let startAnnotation = Artwork(
            title: "출발",
            coordinate: CLLocationCoordinate2D(
                latitude: self.viewModel.trackData[self.cellIndex].points.first?.latitude ?? 0.0,
                longitude: self.viewModel.trackData[self.cellIndex].points.first?.longitude ?? 0.0
            )
        )
        
        let endAnnotation = Artwork(
            title: "도착",
            coordinate: CLLocationCoordinate2D(
                latitude: self.viewModel.trackData[self.cellIndex].points.last?.latitude ?? 0.0,
                longitude: self.viewModel.trackData[self.cellIndex].points.last?.longitude ?? 0.0
            )
        )
        
        mapView.addAnnotation(startAnnotation)
        mapView.addAnnotation(endAnnotation)
        
        // 지도를 나타낼 영역 설정
        guard let deltaCoordinate = self.viewModel.getDeltaCoordinate() else { return }
        
        var rect = MKCoordinateRegion(routeLine.boundingMapRect)
        rect.span.latitudeDelta = deltaCoordinate.0
        rect.span.longitudeDelta = deltaCoordinate.1
        
        self.mapView.setRegion(rect, animated: true)
        self.mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: rect),
                                       animated: false)
    }
    
    // BackView 설정
    private func setupBackView() {

    }
    
    // 산책길 등록 취소 버튼 설정
    private func setupCloseButton() {
        self.closeButton.layer.cornerRadius = self.closeButton.frame.height / 2.0
        self.closeButton.clipsToBounds = true
        
        self.closeButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                print("닫기 버튼 터치됨")
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }

}

//MARK: - extension for DetailInfoViewController

extension DetailInfoViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Artwork else { return nil }
        
        let identifier = "artwork"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView
            .dequeueReusableAnnotationView(withIdentifier: identifier) as? RouteAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier
            )
            view.markerTintColor = annotation.title == "출발" ? UIColor.green : UIColor.red
            view.canShowCallout = false
            //view.image = UIImage(systemName: "star.fill")
        }
        
        return view
    }
        

    
    // 경로를 표시하기 위한 polyline의 렌더링 설정
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let routeLine = overlay as? MKPolyline else { return MKOverlayRenderer() }
        let renderer = MKPolylineRenderer(polyline: routeLine)
        
        renderer.strokeColor = K.Color.mainColor
        renderer.lineWidth = 5.0
        renderer.alpha = 1.0
        
        return renderer
    }
    
}
