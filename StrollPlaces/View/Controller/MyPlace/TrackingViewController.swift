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
    private let isTrackButtonTapped = PublishSubject<Bool>()
    
    //MARK: - UI property
    
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRealm()
        getLocationUsagePermission()
        setupMapView()
        setupLabel()
        setupTimerButton()
        setupResetButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel.clearTrackDataArray()
    }
    
    //MARK: - directly called method
    
    // Realm DB 설정
    private func setupRealm() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    // 지도 및 경로 관련 설정
    private func setupMapView() {
        self.mapView.layer.cornerRadius = 20
        self.mapView.clipsToBounds = true
        self.mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(.follow, animated: true)
        self.mapView.isZoomEnabled = true
        self.mapView.delegate = self
    }
    
    // label 설정
    private func setupLabel() {
        self.viewModel.timeRelay.asDriver(onErrorJustReturn: "timeRealy error")
            .drive(self.timeLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.distanceRelay.asDriver(onErrorJustReturn: "distanceRelay error")
            .drive(self.distanceLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.locationRelay.asDriver(onErrorJustReturn: "locationRelay error")
            .drive(self.locationLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    // 타이머 버튼 설정
    private func setupTimerButton() {
        self.isTrackingAllowed = false
        
        self.timerButton.layer.cornerRadius = self.timerButton.frame.height / 2.0
        self.timerButton.clipsToBounds = true
//        self.timerButton.titleLabel?.font = UIFont.systemFont(ofSize: 20,
//                                                              weight: .bold)
        
        self.timerButton.rx.controlEvent(.touchUpInside).asObservable()
            .debug("타이머 버튼 클릭")
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                if self.isTrackingAllowed {
                    print("추적중입니다.")
                    self.deactivateTimer()
                    DispatchQueue.main.async {
                        //self.timerButton.setTitle("시작", for: .normal)
                        let attributedText = NSAttributedString(
                            string: "시작",
                            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)]
                        )
                        self.timerButton.setAttributedTitle(attributedText, for: .normal)
                    }
                } else {
                    print("추적중이 아닙니다.")
                    self.activateTimer()
                    DispatchQueue.main.async {
                        //self.timerButton.setTitle("종료", for: .normal)
                    }
                    let attributedText = NSAttributedString(
                        string: "종료",
                        attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)]
                    )
                    self.timerButton.setAttributedTitle(attributedText, for: .normal)

                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func setupResetButton() {
        self.resetButton.layer.cornerRadius = self.timerButton.frame.height / 2.0
        self.resetButton.clipsToBounds = true
//        self.timerButton.titleLabel?.font = UIFont.systemFont(ofSize: 20,
//                                                              weight: .bold)
        
        self.resetButton.rx.controlEvent(.touchUpInside).asObservable()
            .skip(until: self.isTrackButtonTapped)
            .debug("초기화 버튼 클릭")
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                // 진짜로 리셋할 것인지 alert message 보여주고 확인받기
                let alert = UIAlertController(title: "확인",
                                              message: "지금까지 측정한 내용을\n모두 초기화 할까요?",
                                              preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "아니요", style: .default)
                let okAction = UIAlertAction(title: "네", style: .destructive) { _ in
                    self.viewModel.stopTimer()
                    self.viewModel.clearTrackDataArray()
                    self.isTrackingAllowed = false
                }
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                
                // 메세지 보여주기
                self.present(alert, animated: true, completion: nil)

            })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - indirectly called method
    
    private func activateTimer() {
        // 타이머 재생, 사용자 위치 업데이트 시작
        self.isTrackingAllowed = true
        self.viewModel.startTimer()
        self.locationManager.startUpdatingLocation()
        
        // trigger 이벤트 발생시키기
        self.isTrackButtonTapped.onNext(true)
    }
    
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
                
                // Realm DB에 track 데이터 저장
                print("self.viewModel.createTrackData()")
                self.viewModel.createTrackData()
            }
        }
    }
    
    // 산책길 등록을 위한 알림 메세지 보여주기
    private func showAlertMessageForRegistration(completion: @escaping (Bool) -> Void) {
        // alert 메세지 설정
        let alert = UIAlertController(title: "확인",
                                      message: "지금까지의 이동 경로를\n나만의 산책길로 등록할까요?",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "아니요", style: .default) { _ in
            completion(false)
        }
        let okAction = UIAlertAction(title: "네", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            guard let nextViewController =
                    self.storyboard?.instantiateViewController(withIdentifier: "AddMyPlaceViewController") as? AddMyPlaceViewController else { return }
            self.navigationController?.pushViewController(nextViewController, animated: true)
            completion(true)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        // 메세지 보여주기
        self.present(alert, animated: true, completion: nil)
    }
    
}
