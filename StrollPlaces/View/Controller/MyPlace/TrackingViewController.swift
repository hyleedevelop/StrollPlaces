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
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
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
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupRealm()
        getLocationUsagePermission()
        setupMapView()
        setupLabel()
        setupTimerButton()
        setupCancelButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.clearTrackDataArray()
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
        navigationController?.setNeedsStatusBarAppearanceUpdate()

        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        
        self.extendedLayoutIncludesOpaqueBars = false
    }
    
    // Realm DB 설정
    private func setupRealm() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    // 지도 및 경로 관련 설정
    private func setupMapView() {
        self.mapView.layer.cornerRadius = 2
        self.mapView.clipsToBounds = true
        self.mapView.layer.borderColor = K.Color.themeGray.cgColor
        self.mapView.layer.borderWidth = 0.5
        self.mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(.follow, animated: true)
        self.mapView.isZoomEnabled = true
        self.mapView.delegate = self
    }
    
    // label 설정
    private func setupLabel() {
        self.viewModel.timeRelay.asDriver(onErrorJustReturn: "알수없음")
            .drive(self.timeLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.distanceRelay.asDriver(onErrorJustReturn: "알수없음")
            .drive(self.distanceLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.locationRelay.asDriver(onErrorJustReturn: "알수없음")
            .drive(self.locationLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        // 글자 하나하나가 일정한 간격을 가지도록 monospaced digit 적용
        self.timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
        self.distanceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
        self.locationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
    }
    
    // 산책길 등록 시작/종료 버튼 설정
    private func setupTimerButton() {
        self.isTrackingAllowed = false
        
        self.timerButton.layer.cornerRadius = self.timerButton.frame.height / 2.0
        self.timerButton.clipsToBounds = true
        self.timerButton.backgroundColor = K.Color.themeYellow
        self.changeButtonUI(buttonTitle: "시작")
        
        self.timerButton.rx.controlEvent(.touchUpInside).asObservable()
            //.skip(until: self.isCountdownOngoing)
            .debug("타이머 버튼 클릭")
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                if self.isTrackingAllowed {
                    // 타이머 비활성화
                    self.deactivateTimer()
                    // 시작/종료 버튼 UI 변경
                    self.changeButtonUI(buttonTitle: "저장")
                    // 잠금화면의 live activity 중단
                    LiveActivityService.shared.deactivate()
                } else {
                    // 카운트다운이 진행되는 동안 타이머 버튼을 작동할 수 없도록 설정
                    //self.timerButton.isEnabled = false
                    
                    // 카운트다운 시작 (SwiftUI 기반의 view 활용)
                    guard !self.isCountdownOngoing else { return }
                    self.showCountdownView {
                        // 타이머 활성화
                        self.activateTimer()
                        // 시작/종료 버튼 UI 변경
                        self.changeButtonUI(buttonTitle: "종료")
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
    private func setupCancelButton() {
        self.resetButton.layer.cornerRadius = self.timerButton.frame.height / 2.0
        self.resetButton.clipsToBounds = true
        self.resetButton.backgroundColor = K.Color.themeGray
        let attributedText = NSAttributedString(
            string: "취소",
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold),
                         NSAttributedString.Key.foregroundColor: K.Color.themeWhite]
        )
        self.resetButton.setAttributedTitle(attributedText, for: .normal)
        
        self.resetButton.rx.controlEvent(.touchUpInside).asObservable()
            //.skip(until: self.isTrackButtonTapped)
            .debug("초기화 버튼 클릭")
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                // 진짜로 리셋할 것인지 alert message 보여주고 확인받기
                let alert = UIAlertController(title: "확인",
                                              message: "경로 생성을 중단할까요?\n지금까지 기록한 경로는 삭제됩니다.",
                                              preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "아니요", style: .default)
                let okAction = UIAlertAction(title: "네", style: .destructive) { _ in
                    // 타이머 중단
                    self.viewModel.stopTimer()
                    // 경로 데이터 초기화
                    self.viewModel.clearTrackDataArray()
                    // 지도 위의 경로 표시 제거
                    self.mapView.removeOverlays(self.mapView.overlays)
                    // 추적 모드 해제
                    self.isTrackingAllowed = false
                    // 잠금화면의 live activity 중단
                    LiveActivityService.shared.deactivate()
                    // 이전 화면으로 돌아가기
                    self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                
                // 메세지 보여주기
                self.present(alert, animated: true, completion: nil)

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
            .debug("카운트다운")
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { count in
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                
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
    
    // 시작/종료 버튼 UI 변경
    private func changeButtonUI(buttonTitle: String) {
        DispatchQueue.main.async {
            let attributedText = NSAttributedString(
                string: buttonTitle,
                attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold),
                             NSAttributedString.Key.foregroundColor: K.Color.themeWhite]
            )
            self.timerButton.setAttributedTitle(attributedText, for: .normal)
        }
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
            // alert action에서 "네"를 클릭한 경우
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
                    
            self.viewModel.goToNextViewController
                .debug("AddMyPlace 화면으로 이동")
                .subscribe(onNext: { isTrue in
                    if isTrue {
                        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddMyPlaceViewController") as? AddMyPlaceViewController else { return }
                        self.navigationController?.pushViewController(nextViewController, animated: true)
                        
                        completion(true)  // okAction에 대한 콜백
                    }
                })
                .disposed(by: rx.disposeBag)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        // 메세지 보여주기
        self.present(alert, animated: true, completion: nil)
    }
    
}
