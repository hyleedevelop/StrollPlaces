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
import Hero

final class DetailInfoViewController: UIViewController {

    //MARK: - IB outlet & action
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelBackView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var featureLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var nameEditButton: UIButton!
    @IBOutlet weak var explanationEditButton: UIButton!
    @IBOutlet weak var featureEditButton: UIButton!
    
    //MARK: - normal property
    
    private let viewModel = DetailInfoViewModel()
    private var locationManager: CLLocationManager!
    private lazy var labelArray = [self.timeLabel, self.distanceLabel, self.ratingLabel,
                                   self.explanationLabel, self.featureLabel, self.dateLabel]
    var cellIndex: Int = 0
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Realm DB에서 데이터 가져오기
        self.viewModel.getTrackDataFromRealmDB(index: self.cellIndex)
        
        self.setupNavigationBar()
        self.setupMapView()
        self.setupLabel()
        self.setupBackView()
        self.setupCloseButton()
        self.setupEditButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        //self.mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: rect),
        //                               animated: false)
    }
    
    // Label 설정
    private func setupLabel() {
        // hero animation
        self.hero.isEnabled = true
        self.nameLabel.hero.id = "nameLabel\(self.cellIndex)"
        
        // UI binding
        self.viewModel.nameRelay.asDriver(onErrorJustReturn: "nameRealy error")
            .drive(self.nameLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.dateRelay.asDriver(onErrorJustReturn: "dateRelay error")
            .drive(self.dateLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.timeRelay.asDriver(onErrorJustReturn: "timeRealy error")
            .drive(self.timeLabel.rx.text)
            .disposed(by: rx.disposeBag)
            
        self.viewModel.distanceRelay.asDriver(onErrorJustReturn: "distanceRealy error")
            .drive(self.distanceLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.explanationRelay.asDriver(onErrorJustReturn: "explanationRelay error")
            .drive(self.explanationLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.featureRelay.asDriver(onErrorJustReturn: "featureRelay error")
            .drive(self.featureLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.ratingRelay.asDriver(onErrorJustReturn: "levelRelay error")
            .drive(self.ratingLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    // BackView 설정
    private func setupBackView() {
        self.labelBackView.layer.cornerRadius = K.Shape.largeCornerRadius
        self.labelBackView.clipsToBounds = true
        self.labelBackView.layer.masksToBounds = false
        self.labelBackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.labelBackView.layer.shadowColor = UIColor.black.cgColor
        self.labelBackView.layer.shadowOpacity = 0.5
        self.labelBackView.layer.shadowRadius = 5
        self.labelBackView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    // 산책길 등록 취소 버튼 설정
    private func setupCloseButton() {
        self.closeButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true) {
                    // 나만의 산책길 목록 화면의 CollectionView Cell 갱신 요청
                    NotificationCenter.default.post(
                        name: Notification.Name("reloadMyPlace"), object: nil
                    )
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    // 편집 버튼 설정
    private func setupEditButton() {
        self.nameEditButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.editItemWithAlertMessage(
                    message: "산책길 이름을 다음과 같이 변경합니다.", placeHolder: "산책길 이름", item: .name
                )
            })
            .disposed(by: rx.disposeBag)
        
        self.explanationEditButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.editItemWithAlertMessage(
                    message: "간단한 소개를 다음과 같이 변경합니다.", placeHolder: "간단한 소개", item: .explanation
                )
            })
            .disposed(by: rx.disposeBag)
        
        self.featureEditButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.editItemWithAlertMessage(
                    message: "특이사항을 다음과 같이 변경합니다.", placeHolder: "특이사항", item: .feature
                )
            })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - indirectly called method
    
    private func editItemWithAlertMessage(message: String, placeHolder: String, item: EditableItems) {
        // alert message 보여주고 입력값 받기
        let alert = UIAlertController(
            title: "수정", message: message, preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "취소", style: .default)
        let okAction = UIAlertAction(title: "저장", style: .default) { _ in
            // TextField에서 입력받은 값을 뷰모델로 전달하여 Realm DB의 업데이트 수행
            guard let text = alert.textFields![0].text else { return }
            self.viewModel.updateDB(index: self.cellIndex, newValue: text, item: item)
        }
        
        // TextField와 Action Button 추가
        alert.addTextField { textField in
            var currentText = ""
            switch item {
            case .name: currentText = self.viewModel.trackData[self.cellIndex].name
            case .explanation: currentText = self.viewModel.trackData[self.cellIndex].explanation
            case .feature: currentText = self.viewModel.trackData[self.cellIndex].feature
            }
            
            textField.text = currentText
            textField.placeholder = placeHolder
            textField.clearButtonMode = .whileEditing
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        // 메세지 보여주기
        self.present(alert, animated: true, completion: nil)
    }

}

//MARK: - extension for DetailInfoViewController

extension DetailInfoViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Artwork {
            
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
        } else {
            return nil
        }
    }
        

    
    // 경로를 표시하기 위한 polyline의 렌더링 설정
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let routeLine = overlay as? MKPolyline else { return MKOverlayRenderer() }
        let renderer = MKPolylineRenderer(polyline: routeLine)
        
        renderer.strokeColor = K.Color.themeBrown
        renderer.lineWidth = K.Map.routeLineWidth
        renderer.alpha = 1.0
        
        return renderer
    }
    
}
