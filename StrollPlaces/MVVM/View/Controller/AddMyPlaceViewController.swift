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
import SPIndicator
import NVActivityIndicatorView
import Cosmos

class AddMyPlaceViewController: UIViewController {

    //MARK: - UI property
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var routeInfoBackView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var nameField: SkyFloatingLabelTextField!
    @IBOutlet weak var explanationField: SkyFloatingLabelTextField!
    @IBOutlet weak var featureField: SkyFloatingLabelTextField!
    @IBOutlet weak var starRating: CosmosView!
    
    @IBOutlet weak var nameCheckLabel: UILabel!
    @IBOutlet weak var explanationCheckLabel: UILabel!
    @IBOutlet weak var featureCheckLabel: UILabel!
    @IBOutlet weak var ratingCheckLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // 로딩 아이콘
    private let activityIndicator: NVActivityIndicatorView = {
        let activityIndicator = NVActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: 40, height: 40),
            type: .ballPulseSync,
            color: K.Color.themeRed,
            padding: .zero)
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    
    //MARK: - normal property
    
    private let viewModel = AddMyPlaceViewModel()
    private let userDefaults = UserDefaults.standard
    private var locationManager: CLLocationManager!
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Realm DB에서 데이터 가져오기
        self.viewModel.getTrackDataFromRealmDB()
        
        self.setupNavigationBar()
        self.setupMapView()
        self.setupBackView()
        self.setupActivityIndicator()
        self.setupLabel()
        self.setupInputResponse()
        self.setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }

    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        self.navigationController?.applyDefaultSettings(hideBar: false)
    }
    
    private func setupMapView() {
        self.mapView.applyDefaultSettings(
            viewController: self, trackingMode: .none, showsUserLocation: false
        )
        self.mapView.layer.cornerRadius = 5
        self.mapView.clipsToBounds = true
        self.mapView.layer.borderColor = K.Color.themeGray.cgColor
        self.mapView.layer.borderWidth = 0.5
        
        // 각 지점들을 기록하고 그 지점들 사이를 선으로 연결
        let points: [CLLocationCoordinate2D] = self.viewModel.getTrackPointForPolyline()
        let routeLine = MKPolyline(coordinates: points, count: points.count)
        
        // 지도에 선 나타내기(addOverlay 시 아래의 rendererFor 함수가 호출됨)
        self.mapView.addOverlay(routeLine)
        
        self.mapView.addAnnotation(self.viewModel.startAnnotation)
        self.mapView.addAnnotation(self.viewModel.endAnnotation)
        
        // 지도를 나타낼 영역 설정
        guard let deltaCoordinate = self.viewModel.getDeltaCoordinate() else { return }

        var rect = MKCoordinateRegion(routeLine.boundingMapRect)
        rect.span.latitudeDelta = deltaCoordinate.0
        rect.span.longitudeDelta = deltaCoordinate.1
        
        self.mapView.setRegion(rect, animated: true)
        self.mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: rect),
                                       animated: false)
        
        // 스냅샷을 이미지로 저장하기
        self.viewModel.saveMapViewAsImage(
            region: rect, size: CGSize(width: 200, height: 200)
        )
    }
    
    // 경로정보 영역의 Back View 설정
    private func setupBackView() {
        self.routeInfoBackView.backgroundColor = K.Color.themeWhite
        self.routeInfoBackView.layer.cornerRadius = 5
        self.routeInfoBackView.clipsToBounds = true
        self.routeInfoBackView.layer.masksToBounds = false
        self.routeInfoBackView.layer.shadowColor = UIColor.black.cgColor
        self.routeInfoBackView.layer.shadowRadius = 3
        self.routeInfoBackView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.routeInfoBackView.layer.shadowOpacity = 0.3
        self.routeInfoBackView.layer.borderColor = UIColor.black.cgColor
        self.routeInfoBackView.layer.borderWidth = 1
    }
    
    // loading indicator 설정
    private func setupActivityIndicator() {
        self.view.addSubview(activityIndicator)
        
        self.activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalTo(self.view.safeAreaLayoutGuide)
        }
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
    }
    
    // TextField 및 TextView 설정
    private func setupInputResponse() {
        let nameObservable = nameField.rx.text.orEmpty
        let explanationObservable = explanationField.rx.text.orEmpty
        let featureObservable = featureField.rx.text.orEmpty
        let ratingObservable = BehaviorSubject<Double>(value: self.starRating.rating)
        
        // 키보드 종류 설정
        [self.nameField, self.explanationField, self.featureField]
            .forEach { $0?.returnKeyType = .default }
        // 별점 항목에서 별을 터치했을 때 수행할 내용
        self.starRating.didTouchCosmos = { ratingObservable.onNext($0) }
        
        nameObservable
            .skip(1)
            .asSignal(onErrorJustReturn: "없음")
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                let str = self.viewModel.limitTextFieldLength($0, self.nameField, isNameField: true)
                let isValid = self.viewModel.checkTextFieldIsValid(str, self.nameField, isNameField: true)
                self.nameCheckLabel.text = isValid ? "✅" : ""
            })
            .disposed(by: rx.disposeBag)
        
        explanationObservable
            .skip(1)
            .asSignal(onErrorJustReturn: "없음")
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                let str = self.viewModel.limitTextFieldLength($0, self.explanationField, isNameField: false)
                let isValid = self.viewModel.checkTextFieldIsValid(str, self.explanationField, isNameField: false)
                self.explanationCheckLabel.text = isValid ? "✅" : ""
            })
            .disposed(by: rx.disposeBag)
        
        featureObservable
            .skip(1)
            .asSignal(onErrorJustReturn: "없음")
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                let str = self.viewModel.limitTextFieldLength($0, self.featureField, isNameField: false)
                let isValid = self.viewModel.checkTextFieldIsValid(str, self.featureField, isNameField: false)
                self.featureCheckLabel.text = isValid ? "✅" : ""
            })
            .disposed(by: rx.disposeBag)
        
        // 문제 해결하기
        ratingObservable
            .map { self.viewModel.checkstarRatingIsValid(value: $0) }
            .subscribe(onNext: { [weak self] isValid in
                guard let self = self else { return }
                self.ratingCheckLabel.text = isValid ? "✅" : ""
            })
            .disposed(by: rx.disposeBag)
        
        // 산책길 이름, 간단한 소개, 특이사항의 모든 TextField 입력값이 유효하면
        // 저장 버튼을 클릭할 수 있도록 활성화
        Observable
            .combineLatest(
                nameObservable
                    .map { self.viewModel.checkTextFieldIsValid($0, self.nameField, isNameField: true) },  // Bool
                explanationObservable
                    .map { self.viewModel.checkTextFieldIsValid($0, self.explanationField, isNameField: false) },  // Bool
                featureObservable
                    .map { self.viewModel.checkTextFieldIsValid($0, self.featureField, isNameField: false) },  // Bool
                ratingObservable
                    .map { self.viewModel.checkstarRatingIsValid(value: $0) },  // Bool
                resultSelector: { e1, e2, e3, e4 in e1 && e2 && e3 && e4 })
            .subscribe(onNext: { [weak self] isAvailable in
                guard let self = self else { return }
                self.saveButton.isEnabled = isAvailable
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func setupButton() {
        // (1) 저장 버튼
        self.saveButton.layer.cornerRadius = 5
        self.saveButton.clipsToBounds = true
        
        self.saveButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                // loading indicator 시작
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                }
                
                // DB 업데이트
                self.viewModel.updateTrackData(
                    name: self.nameField.text!,
                    explanation: self.explanationField.text!,
                    feature: self.featureField.text!,
                    rating: self.starRating.rating
                ) {
                    // 나만의 산책길 목록이 비어있는지의 여부를 UserDefaults에 저장
                    self.userDefaults.set(true, forKey: "myPlaceExist")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        // loading indicator 종료
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                        }
                        
                        // Tab Bar 뱃지의 숫자 업데이트 알리기
                        NotificationCenter.default.post(name: Notification.Name("updateBadge"), object: nil)
                        
                        // 완료 메세지 표시
                        SPIndicatorService.shared.showIndicator(title: "생성 완료")
                        
                        // 나만의 산책길 탭 메인화면으로 돌아가기
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        // (2) 취소 버튼
        self.cancelButton.layer.cornerRadius = 5
        self.cancelButton.clipsToBounds = true
        
        self.cancelButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.actionForMarkRemoval(viewController: self)
            })
            .disposed(by: rx.disposeBag)
    }
    
}

extension AddMyPlaceViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return MapService.shared.getAnnotationView(mapView: mapView, annotation: annotation)
    }
    
    // 경로를 표시하기 위한 polyline의 렌더링 설정
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return MapService.shared.getOverlayRenderer(mapView: mapView, overlay: overlay)
    }
    
}
