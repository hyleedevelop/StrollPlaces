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
import PhotosUI
import SPIndicator

class AddMyPlaceViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var routeInfoBackView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var endLocationLabel: UILabel!
    
    @IBOutlet weak var nameField: SkyFloatingLabelTextField!
    @IBOutlet weak var explanationField: SkyFloatingLabelTextField!
    @IBOutlet weak var featureField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var nameCheckLabel: UILabel!
    @IBOutlet weak var explanationCheckLabel: UILabel!
    @IBOutlet weak var featureCheckLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //MARK: - normal property
    
    private let viewModel = AddMyPlaceViewModel()
    private let userDefaults = UserDefaults.standard
    private var locationManager: CLLocationManager!
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Realm DB에서 데이터 가져오기
        self.viewModel.getTrackDataFromRealmDB()
        
        setupNavigationBar()
        setupMapView()
        setupBackView()
        setupLabel()
        setupTextField()
        setupButton()
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
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNeedsStatusBarAppearanceUpdate()

        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    private func setupMapView() {
        self.mapView.layer.cornerRadius = 2
        self.mapView.clipsToBounds = true
        self.mapView.layer.borderColor = K.Color.themeGray.cgColor
        self.mapView.layer.borderWidth = 0.5
        self.mapView.showsUserLocation = false
        self.mapView.setUserTrackingMode(.none, animated: true)
        self.mapView.isZoomEnabled = true
        self.mapView.delegate = self
        
        // 각 지점들을 기록하고 그 지점들 사이를 선으로 연결
        let points: [CLLocationCoordinate2D] = self.viewModel.getTrackPointForPolyline()
        let routeLine = MKPolyline(coordinates: points, count: points.count)
        
        // 지도에 선 나타내기(addOverlay 시 아래의 rendererFor 함수가 호출됨)
        self.mapView.addOverlay(routeLine)
        
        // 지도를 나타낼 영역 설정
        guard let deltaCoordinate = self.viewModel.getDeltaCoordinate() else {
            print("에러")
            return
        }
        
        var rect = MKCoordinateRegion(routeLine.boundingMapRect)
        rect.span.latitudeDelta = deltaCoordinate.0
        rect.span.longitudeDelta = deltaCoordinate.1
        
        self.mapView.setRegion(rect, animated: true)
        self.mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: rect),
                                       animated: false)
    }
    
    // 경로정보 영역의 Back View 설정
    private func setupBackView() {
        self.routeInfoBackView.backgroundColor = K.Color.themeWhite
        self.routeInfoBackView.layer.cornerRadius = 20
        self.routeInfoBackView.clipsToBounds = true
        self.routeInfoBackView.layer.masksToBounds = false
        //self.routeInfoBackView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.routeInfoBackView.layer.shadowColor = UIColor.black.cgColor
        self.routeInfoBackView.layer.shadowRadius = 3
        self.routeInfoBackView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.routeInfoBackView.layer.shadowOpacity = 0.3
        self.routeInfoBackView.layer.borderColor = K.Color.themeBlack.cgColor
        self.routeInfoBackView.layer.borderWidth = 1
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
        
        self.viewModel.firstLocationRelay.asDriver(onErrorJustReturn: "firstLocationRelay error")
            .drive(self.startLocationLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.lastLocationRelay.asDriver(onErrorJustReturn: "lastLocationRelay error")
            .drive(self.endLocationLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    // TextField 및 TextView 설정
    private func setupTextField() {
        self.nameField.errorColor = UIColor.red
        self.nameField.returnKeyType = .default
        
        let nameObservable = nameField.rx.text.orEmpty
        let explanationObservable = explanationField.rx.text.orEmpty
        let featureObservable = featureField.rx.text.orEmpty
        
        nameObservable
            .skip(1)
            .asSignal(onErrorJustReturn: "없음")
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                let str = self.limitTextFieldLength($0, self.nameField)
                let isValid = self.checkTextFieldIsValid(str, self.nameField)
                self.nameCheckLabel.text = isValid ? "✅" : ""
            })
            .disposed(by: rx.disposeBag)
        
        explanationObservable
            .skip(1)
            .asSignal(onErrorJustReturn: "없음")
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                let str = self.limitTextFieldLength($0, self.explanationField)
                let isValid = self.checkTextFieldIsValid(str, self.explanationField)
                self.explanationCheckLabel.text = isValid ? "✅" : ""
            })
            .disposed(by: rx.disposeBag)
        
        featureObservable
            .skip(1)
            .asSignal(onErrorJustReturn: "없음")
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                let str = self.limitTextFieldLength($0, self.featureField)
                let isValid = self.checkTextFieldIsValid(str, self.featureField)
                self.featureCheckLabel.text = isValid ? "✅" : ""
            })
            .disposed(by: rx.disposeBag)
        
        // 산책길 이름, 간단한 소개, 특이사항의 모든 TextField 입력값이 유효하면
        // 저장 버튼을 클릭할 수 있도록 활성화
        Observable
            .combineLatest(
                nameObservable
                    .map({ self.checkTextFieldIsValid($0, self.nameField) }),
                explanationObservable
                    .map({ self.checkTextFieldIsValid($0, self.explanationField) }),
                featureObservable
                    .map({ self.checkTextFieldIsValid($0, self.featureField) }),
                resultSelector: { s1, s2, s3 in
                    s1 && s2 && s3  // Bool
                })
            .subscribe(onNext: { [weak self] isGoodToActivate in
                guard let self = self else { return }
                self.saveButton.isEnabled = isGoodToActivate
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func setupButton() {
        // (1) 저장 버튼
        self.saveButton.layer.cornerRadius = self.saveButton.frame.height / 2.0
        self.saveButton.clipsToBounds = true
        
        self.saveButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                if self.nameField.text != nil &&
                   self.explanationField.text != nil &&
                   self.featureField.text != nil {
                    self.viewModel.updateTrackData(
                        name: self.nameField.text!,
                        explanation: self.explanationField.text!,
                        feature: self.featureField.text!
                    )
                    
                    // 스위치의 값을 UserDefaults에 저장
                    self.userDefaults.set(true, forKey: "myPlaceExist")
                    
                    let indicatorView = SPIndicatorView(title: "저장 완료", preset: .done)
                    indicatorView.present(duration: 2.0, haptic: .success)
                } else {
                    print("산책길 이름을 입력하세요")
                }
                
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
                self.showAlertMessageForReturn()
            })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - indirectly called method
    
    private func showAlertMessageForReturn() {
        // 진짜로 취소할 것인지 alert message 보여주고 확인받기
        let alert = UIAlertController(title: "확인",
                                      message: "지금까지 작성한 내용을\n모두 삭제할까요?",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "아니요", style: .default)
        let okAction = UIAlertAction(title: "네", style: .destructive) { _ in
            // Realm DB에 임시로 저장했던 경로 삭제하기
            self.viewModel.clearTemporaryTrackData()
            // 이전화면(경로만들기)로 돌아가기
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        // 메세지 보여주기
        self.present(alert, animated: true, completion: nil)
    }
 
    // TextField의 글자수 제한을 넘기면 초과되는 부분은 입력되지 않도록 설정
    private func limitTextFieldLength(_ text: String, _ textField: UITextField) -> String {
        let maxLength: Int = (textField == self.nameField) ? 10 : 20
        if text.count > maxLength {
            let index = text.index(text.startIndex, offsetBy: maxLength)
            textField.text = String(text[..<index])
            return String(text[..<index])
        } else {
            return text
        }
    }
    
    // TextField에 입력된 문자열에 대한 유효성 검사
    private func checkTextFieldIsValid(_ text: String, _ textField: UITextField) -> Bool {
        let maxLength: Int = (textField == self.nameField) ? 10 : 20
        return (1...maxLength) ~= text.count
    }
    
}

extension AddMyPlaceViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? RouteAnnotation {
            let view = MKAnnotationView(annotation: annotation,
                                        reuseIdentifier: "RouteAnnotationView")
            view.image = UIImage(systemName: "location.circle.fill")
            return view
        }
        return nil
    }
    
    // 경로를 표시하기 위한 polyline의 렌더링 설정
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let routeLine = overlay as? MKPolyline else { return MKOverlayRenderer() }
        let renderer = MKPolylineRenderer(polyline: routeLine)
        
        renderer.strokeColor = K.Color.themeYellow
        renderer.lineWidth = 4.0
        renderer.alpha = 1.0
        
        return renderer
    }
    
}
