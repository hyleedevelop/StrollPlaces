//
//  TrackingViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/29.
//

import UIKit
import SnapKit
import CoreLocation
import MapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RealmSwift
import SwiftUI

final class TrackingViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelBackView: UIView!
    @IBOutlet weak var closeButtonBackView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    //MARK: - normal property
    
    internal lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        manager.delegate = self
        return manager
    }()
    
    internal let viewModel = TrackingViewModel()
    internal var previousCoordinate: CLLocationCoordinate2D?
    internal var isTrackingAllowed = false
    private var isCountdownOngoing = false
    private let isTrackButtonTapped = PublishSubject<Bool>()
    
    // 사용자의 현재 위치를 받아오고, 이를 중심으로 regionRadius 반경만큼의 영역을 보여주기
    var currentLocation: CLLocation {
        let latitude = ((locationManager.location?.coordinate.latitude) ?? K.Map.defaultLatitude) as Double
        let longitude = ((locationManager.location?.coordinate.longitude) ?? K.Map.defaultLongitude) as Double
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(Realm.Configuration.defaultConfiguration.fileURL!)
        self.setupNavigationBar()
        self.getLocationUsagePermission()
        self.setupMapView()
        self.setupBackView()
        self.setupLabel()
        self.setupTimerButton()
        self.setupCloseButton()
        
        MapService.shared.moveToCurrentLocation(
            manager: self.locationManager, mapView: self.mapView
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        self.locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.clearTrackDataArray()
        self.locationManager.stopUpdatingLocation()
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        self.navigationController?.applyDefaultSettings(hideBar: true)
    }
    
    // 지도 및 경로 관련 설정
    private func setupMapView() {
        self.mapView.delegate = self
        self.mapView.applyDefaultSettings(
            viewController: self, trackingMode: .follow, showsUserLocation: true
        )
        
        self.locationManager.startUpdatingLocation()
        
        // 카메라 줌아웃 제한 설정
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 2000.km)
        self.mapView.setCameraZoomRange(zoomRange, animated: true)
    }
    
    private func setupBackView() {
        self.labelBackView.setHalfRoundedCornerBackView()
    }
    
    // label 설정
    private func setupLabel() {
        // 글자 하나하나가 일정한 간격을 가지도록 monospaced digit 적용
        self.timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
        self.distanceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
        self.locationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
        
        self.viewModel.timeRelay.asDriver(onErrorJustReturn: "알수없음")
            .drive(self.timeLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.distanceRelay.asDriver(onErrorJustReturn: "알수없음")
            .drive(self.distanceLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.locationRelay.asDriver(onErrorJustReturn: "알수없음")
            .drive(self.locationLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    // 산책길 등록 시작/종료 버튼 설정
    private func setupTimerButton() {
        self.isTrackingAllowed = false
        
        self.timerButton.layer.cornerRadius = K.Shape.mediumCornerRadius
        self.timerButton.clipsToBounds = true
        self.timerButton.backgroundColor = K.Color.mainColor
        self.timerButton.changeAttributes(buttonTitle: "산책길 경로 생성", interaction: true)
        
        self.timerButton.rx.controlEvent(.touchUpInside).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                if self.isTrackingAllowed {
                    // 타이머 비활성화
                    self.deactivateTimer()
                    // 시작/종료 버튼 UI 변경
                    self.timerButton.changeAttributes(buttonTitle: "산책길 경로 저장", interaction: true)
                    // 잠금화면의 live activity 중단
                    LiveActivityService.shared.deactivate()
                } else {
                    // 카운트다운이 진행되는 동안 타이머 버튼을 작동할 수 없도록 설정
                    self.timerButton.changeAttributes(buttonTitle: "카운트다운 진행중", interaction: false)
                    // 카운트다운 시작 (SwiftUI 기반의 view 활용)
                    guard !self.isCountdownOngoing else { return }
                    self.showCountdownView {
                        // 타이머 활성화
                        self.activateTimer()
                        // 시작/종료 버튼 UI 변경
                        self.timerButton.changeAttributes(buttonTitle: "경로 생성 종료", interaction: true)
                        // 잠금화면의 live activity 시작
                        LiveActivityService.shared.activate()
                    }
                    // 카운트다운 종료 이후부터 타이머 버튼을 작동할 수 있도록 설정
                    //self.timerButton.isEnabled = true
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    // 산책길 등록 취소 버튼 설정
    private func setupCloseButton() {
        self.closeButton.layer.cornerRadius = self.closeButton.frame.height / 2.0
        self.closeButton.clipsToBounds = true
        
        self.closeButton.rx.controlEvent(.touchUpInside).asObservable()
            //.skip(until: self.isTrackButtonTapped)
            .debug("초기화 버튼 클릭")
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.viewModel.getActionForStopTracking(
                    viewController: self, mapView: self.mapView
                )
                self.isTrackingAllowed = false
            })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - indirectly called method
    
    // 타이머 활성화 시작 전, 카운트다운 보여주기
    private func showCountdownView(completion: @escaping () -> Void) {
        self.isCountdownOngoing = true
        
        // 참고: countdownView는 SwiftUI로 만들어졌음
        let countdownViewController = UIHostingController(rootView: AnimatedCountdownView())
        let countdownView = countdownViewController.view!
        let animatedCountdownView = countdownViewController.rootView
        
        self.view.addSubview(countdownView)
        
        countdownView.layer.cornerRadius = 75
        countdownView.clipsToBounds = true
        countdownView.layer.masksToBounds = false
        countdownView.layer.shadowColor = UIColor.black.cgColor
        countdownView.layer.shadowOpacity = 0.8
        countdownView.layer.shadowRadius = 10
        countdownView.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        countdownView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(150)
        }
            
        animatedCountdownView.countdownValue
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { count in
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                
                if count == 0.0 {
                    UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseIn) {
                        countdownView.alpha = 0.0
                    } completion: { _ in
                        countdownView.removeFromSuperview()
                    }
                    
                    completion()
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    // 타이머 활성화
    private func activateTimer() {
        // 타이머 재생, 사용자 위치 업데이트 시작
        self.isTrackingAllowed = true
        self.viewModel.startTimer()
        self.locationManager.startUpdatingLocation()
        
        // trigger 이벤트 발생시키기
        self.isTrackButtonTapped.onNext(true)
    }
    
    // 타이머 비활성화
    private func deactivateTimer() {
        // 타이머 일시정지, 사용자 위치 업데이트 중지
        self.viewModel.pauseTimer()
        self.locationManager.stopUpdatingLocation()
        
        // alert message 보여주기
        self.showAlertMessageForRegistration { timerShouldBeStopped in
            // alert action에서 "네(저장)"를 클릭한 경우
            if timerShouldBeStopped {
                // 타이머를 종료하고 Realm DB에 경로 기록하기
                self.isTrackingAllowed = false
                self.viewModel.stopTimer()
            }
        }
    }
    
    // 산책길 등록을 위한 알림 메세지 보여주기
    private func showAlertMessageForRegistration(completion: @escaping (Bool) -> Void) {
        // alert 메세지 설정
        let alert = UIAlertController(title: "확인",
                                      message: "지금까지 생성한 경로를\n나만의 산책길로 저장할까요?",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "아니요", style: .default) { _ in
            completion(false)
        }
        let okAction = UIAlertAction(title: "네", style: .default) { [weak self] _ in
            // 다음 화면으로 이동
            guard let self = self else { return }
            
            // Realm DB에 track data 저장
            self.viewModel.createTrackData()
                    
            self.viewModel.shouldNextViewControllerAppear
                .filter { $0 == true }
                .subscribe(onNext: { _ in
                    guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: K.Identifier.addMyPlaceVC) as? AddMyPlaceViewController else { return }
                    self.navigationController?.pushViewController(nextViewController, animated: true)
                    
                    completion(true)  // okAction에 대한 콜백
                })
                .disposed(by: rx.disposeBag)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        // 메세지 보여주기
        self.present(alert, animated: true, completion: nil)
    }
    
}
