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

final class TrackingViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var trackStartButton: UIButton!
    @IBOutlet weak var trackPauseButton: UIButton!
    @IBOutlet weak var trackStopButton: UIButton!
    
    //MARK: - normal property
    private var hours: Int = 0
    private var minutes: Int = 0
    private var seconds: Int = 0
    private var timer: Timer? = nil
    
    //MARK: - UI property
    
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        
        setupPlayButton()
        setupPauseButton()
        setupStopButton()
    }
    
    //MARK: - directly called method
    
    // 지도 설정
    private func setupMapView() {
        self.mapView.layer.cornerRadius = 20
        self.mapView.clipsToBounds = true
    
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
                self.deactivateButton(button: self.trackStartButton)
                self.indicateSelectedButton(button: self.trackStartButton)
                
                /* 지도에 경로 표시하고 Realm DB에 기록하기 */
                
                self.startTimer()
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
                self.deactivateButton(button: self.trackPauseButton)
                self.indicateSelectedButton(button: self.trackPauseButton)
                
                self.pauseTimer()
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
                self.deactivateButton(button: self.trackStopButton)
                self.indicateSelectedButton(button: self.trackStopButton)
                
                self.pauseTimer()
                self.showAlertMessageForRegistration { timerShouldBeStopped in
                    // alert action에서 "네"를 클릭한 경우 타이머 기록 초기화
                    if timerShouldBeStopped { self.stopTimer() }
                }
                
                /* 지도에 경로 표시하고 Realm DB에 기록하기 */
                
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    //MARK: - indirectly called method

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let addMyPlaceViewController = segue.destination as? AddMyPlaceViewController else { return }
        //addMyPlaceViewController.xxx = xxx
    }
    
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
            self.performSegue(withIdentifier: "ToAddMyPlaceViewController", sender: nil)
            completion(true)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
