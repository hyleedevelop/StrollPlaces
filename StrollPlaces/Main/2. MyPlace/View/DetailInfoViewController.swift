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
    
    var viewModel: DetailInfoViewModel!
    var cellIndex: Int = 0
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // viewModel 초기화
        self.viewModel = DetailInfoViewModel(cellIndex: self.cellIndex)
        
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
        self.navigationController?.applyDefaultSettings(hideBar: true)
    }

    // MapView 설정
    private func setupMapView() {
        self.mapView.applyDefaultSettings(
            viewController: self, trackingMode: .none, showsUserLocation: false
        )
        
        // 각 지점들을 기록하고 그 지점들 사이를 선으로 연결
        let points: [CLLocationCoordinate2D] =
        self.viewModel.getTrackPointForPolyline(index: self.cellIndex)
        let routeLine = MKPolyline(coordinates: points, count: points.count)
        
        // 지도에 선 나타내기(addOverlay 시 아래의 rendererFor 함수가 호출됨)
        self.mapView.addOverlay(routeLine)
        
        // 출발, 도착 지점 표시하기
        self.mapView.addAnnotation(self.viewModel.startAnnotation)
        self.mapView.addAnnotation(self.viewModel.endAnnotation)
        
        // 지도를 나타낼 영역 설정
        guard let deltaCoordinate = self.viewModel.getDeltaCoordinate() else { return }
        var rect = MKCoordinateRegion(routeLine.boundingMapRect)
        rect.span.latitudeDelta = deltaCoordinate.0
        rect.span.longitudeDelta = deltaCoordinate.1
        self.mapView.setRegion(rect, animated: true)
    }
    
    // Label 설정
    private func setupLabel() {
        self.hero.isEnabled = true
        self.nameLabel.hero.id = "nameLabel\(self.cellIndex)"
        self.timeLabel.hero.id = "timeLabel\(self.cellIndex)"
        self.distanceLabel.hero.id = "distanceLabel\(self.cellIndex)"
        
        self.viewModel.nameRelay.asDriver(onErrorJustReturn: "")
            .drive(self.nameLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.dateRelay.asDriver(onErrorJustReturn: "")
            .drive(self.dateLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.timeRelay.asDriver(onErrorJustReturn: "")
            .drive(self.timeLabel.rx.text)
            .disposed(by: rx.disposeBag)
            
        self.viewModel.distanceRelay.asDriver(onErrorJustReturn: "")
            .drive(self.distanceLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.explanationRelay.asDriver(onErrorJustReturn: "")
            .drive(self.explanationLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.featureRelay.asDriver(onErrorJustReturn: "")
            .drive(self.featureLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.ratingRelay.asDriver(onErrorJustReturn: "")
            .drive(self.ratingLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    // BackView 설정
    private func setupBackView() {
        self.labelBackView.setHalfRoundedCornerBackView()
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
                self.viewModel.editItemWithAlertMessage(
                    cellIndex: self.cellIndex,
                    item: .name,
                    viewController: self
                )
            })
            .disposed(by: rx.disposeBag)
        
        self.explanationEditButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.editItemWithAlertMessage(
                    cellIndex: self.cellIndex,
                    item: .explanation,
                    viewController: self
                )
            })
            .disposed(by: rx.disposeBag)
        
        self.featureEditButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.editItemWithAlertMessage(
                    cellIndex: self.cellIndex,
                    item: .feature,
                    viewController: self
                )
            })
            .disposed(by: rx.disposeBag)
    }

}

//MARK: - extension for MKMapViewDelegate

extension DetailInfoViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return self.viewModel.annotationView(mapView: mapView, annotation: annotation)
    }
    
    // 경로를 표시하기 위한 polyline의 렌더링 설정
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return self.viewModel.overlayRenderer(mapView: mapView, overlay: overlay)
    }
    
}
