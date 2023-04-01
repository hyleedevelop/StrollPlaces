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
import RealmSwift

final class TrackingViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var trackStartButton: UIButton!
    @IBOutlet weak var trackPauseButton: UIButton!
    @IBOutlet weak var trackStopButton: UIButton!
    
    @IBAction func resetTrack() {
        self.stopTimer()
    }
    
    //MARK: - normal property
    private var hours: Int = 0
    private var minutes: Int = 0
    private var seconds: Int = 0
    private var timer: Timer? = nil
    
    internal lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        manager.delegate = self
        return manager
    }()
    
    internal var previousCoordinate: CLLocationCoordinate2D?
    internal var trackData = TrackData()
    internal var isTrackingAllowed = false
    
    //MARK: - UI property
    
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRealm()
        
        getLocationUsagePermission()
        setupMapAndTrack()
        
        setupPlayButton()
        setupPauseButton()
        setupStopButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.locationManager.stopUpdatingLocation()
    }
    
    //MARK: - directly called method
    
    // RealmDB 설정
    private func setupRealm() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    // 지도 및 경로 관련 설정
    private func setupMapAndTrack() {
        self.mapView.layer.cornerRadius = 20
        self.mapView.clipsToBounds = true
        self.mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(.follow, animated: true)
        self.mapView.isZoomEnabled = true
        self.mapView.delegate = self
        
        // 경로 저장 날짜 = 현재 날짜
        self.trackData.date = Date()
        self.isTrackingAllowed = false
    }
    
    // 타이머 시작 버튼 설정
    private func setupPlayButton() {
        self.trackStartButton.layer.cornerRadius = self.trackStartButton.frame.height / 2.0
        self.trackStartButton.clipsToBounds = true
        
        self.trackStartButton.rx.controlEvent(.touchUpInside).asObservable()
            .debug("타이머 시작 이벤트")
            //.debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                // 버튼 활성화 여부 및 UI 업데이트
                self.deactivateButton(button: self.trackStartButton)
                self.indicateSelectedButton(button: self.trackStartButton)
                
                // 타이머 재생, 사용자 위치 업데이트 시작
                self.isTrackingAllowed = true
                self.startTimer()
                self.locationManager.startUpdatingLocation()
            })
            .disposed(by: rx.disposeBag)
    }
    
    // 타이머 일시정지 버튼 설정
    private func setupPauseButton() {
        self.trackPauseButton.layer.cornerRadius = self.trackStartButton.frame.height / 2.0
        self.trackPauseButton.clipsToBounds = true
        
        self.trackPauseButton.rx.controlEvent(.touchUpInside).asObservable()
            .debug("타이머 일시정지 이벤트")
            //.debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                // 버튼 활성화 여부 및 UI 업데이트
                self.deactivateButton(button: self.trackPauseButton)
                self.indicateSelectedButton(button: self.trackPauseButton)
                
                // 타이머 일시정지, 사용자 위치 업데이트 중지
                self.isTrackingAllowed = false
                self.pauseTimer()
                self.locationManager.stopUpdatingLocation()
            })
            .disposed(by: rx.disposeBag)
    }
     
    // 타이머 중단 버튼 설정
    private func setupStopButton() {
        self.trackStopButton.layer.cornerRadius = self.trackStartButton.frame.height / 2.0
        self.trackStopButton.clipsToBounds = true
        
        self.trackStopButton.rx.controlEvent(.touchUpInside).asObservable()
            .debug("타이머 중단 이벤트")
            //.debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                // 버튼 활성화 여부 및 UI 업데이트
                self.deactivateButton(button: self.trackStopButton)
                self.indicateSelectedButton(button: self.trackStopButton)
                
                // 타이머 일시정지, 사용자 위치 업데이트 중지
                self.pauseTimer()
                self.locationManager.stopUpdatingLocation()
                
                // alert message 보여주기
                self.showAlertMessageForRegistration { timerShouldBeStopped in
                    // alert action에서 "네"를 클릭한 경우
                    if timerShouldBeStopped {
                        // 타이머를 종료하고 Realm DB에 경로 기록하기
                        self.isTrackingAllowed = false
                        self.stopTimer()
                        RealmService.shared.create(self.trackData)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    //MARK: - indirectly called method

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let addMyPlaceViewController = segue.destination as? AddMyPlaceViewController else { return }
//        //addMyPlaceViewController.xxx = xxx
//    }
    
    // 선택된 버튼은 테두리를 표시하고, 선택되지 않은 버튼은 테두리를 없애도록 설정
    private func indicateSelectedButton(button: UIButton) {
        button.layer.borderColor = K.Color.mainColor.cgColor
        button.layer.borderWidth = 2
        
        switch button {
        case self.trackStartButton:
            self.trackPauseButton.layer.borderWidth = 0
            self.trackStopButton.layer.borderWidth = 0
        case self.trackPauseButton:
            self.trackStartButton.layer.borderWidth = 0
            self.trackStopButton.layer.borderWidth = 0
        case self.trackStopButton:
            self.trackStartButton.layer.borderWidth = 0
            self.trackPauseButton.layer.borderWidth = 0
        default:
            break
        }
    }
    
    private func deactivateButton(button: UIButton) {
        switch button {
        case self.trackStartButton:
            self.trackStartButton.isUserInteractionEnabled = false
            self.trackPauseButton.isUserInteractionEnabled = true
            self.trackStopButton.isUserInteractionEnabled = true
        case self.trackPauseButton:
            self.trackStartButton.isUserInteractionEnabled = true
            self.trackPauseButton.isUserInteractionEnabled = false
            self.trackStopButton.isUserInteractionEnabled = true
        case self.trackStopButton:
            self.trackStartButton.isUserInteractionEnabled = true
            self.trackPauseButton.isUserInteractionEnabled = true
            self.trackStopButton.isUserInteractionEnabled = true
        default:
            break
        }
    }
    
    // 타이머 시작
    private func startTimer() {
        invalidateTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            // 시간(시, 분, 초) 계산
            if self.seconds == 59 {
                self.seconds = 0
                if self.minutes == 59 {
                    self.minutes = 0
                    self.hours += 1
                } else {
                    self.minutes += 1
                }
            } else {
                self.seconds += 1
            }
            
            self.timeLabel.text = String(
                format: "%02i:%02i:%02i", self.hours, self.minutes, self.seconds
            )
        }
    }
    
    // 타이머 일시정지
    private func pauseTimer() {
        invalidateTimer()
    }
    
    // 타이머 중단
    private func stopTimer() {
        invalidateTimer()
        
        self.seconds = 0
        self.minutes = 0
        self.hours = 0
        self.timeLabel.text = String(
            format:"%02i:%02i:%02i", self.hours, self.minutes, self.seconds
        )
    }
    
    // 타이머 초기화
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 산책길 등록을 위한 알림 메세지 보여주기
    private func showAlertMessageForRegistration(completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "확인",
                                      message: "지금까지의 이동 경로를\n나만의 산책길로 등록할까요?",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "아니요", style: .default) { _ in
            completion(false)
        }
        let okAction = UIAlertAction(title: "네", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddMyPlaceViewController")
                    as? AddMyPlaceViewController else { return }
            nextViewController.modalPresentationStyle = .overFullScreen
            self.present(nextViewController, animated: true, completion: nil)
            completion(true)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
