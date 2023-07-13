//
//  TrackingViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/02.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RealmSwift
import CoreLocation
import MapKit

final class TrackingViewModel: CommonViewModel {
    
    //MARK: - 생성자 관련
    
    override init() {
        
    }
    
    //MARK: - 산책길 생성 관련
    
    // 시간 및 타이머 속성
    private var hours: Int = 0
    private var minutes: Int = 0
    private var seconds: Int = 0
    private var timer: Timer? = nil
    
    // 산책길 생성 화면의 UI 바인딩
    let timeRelay = BehaviorRelay<String>(value: "00:00:00")
    let distanceRelay = BehaviorRelay<String>(value: "0.0m")
    let locationRelay = BehaviorRelay<String>(value: "-")
    var timeString: String = ""
    
    // 타이머 시작
    func startTimer() {
        self.invalidateTimer()
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
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
            
            // 화면에 표출할 시간 문자열 설정
            self.timeString = String(format: "%02i:%02i:%02i", self.hours, self.minutes, self.seconds)
            
            // label text 바인딩을 위한 시간 문자열 방출
            self.timeRelay.accept(self.timeString)
            
            // live widget에 표출할 시간 문자열 전달 및 widget UI 업데이트
            LiveActivityService.shared.timeString = self.timeString
            LiveActivityService.shared.update()
        }
    }
    
    // 타이머 일시정지
    func pauseTimer() {
        self.invalidateTimer()
    }
    
    // 타이머 중단
    func stopTimer() {
        self.invalidateTimer()
        
        self.seconds = 0
        self.minutes = 0
        self.hours = 0
        
        self.timeRelay.accept("00:00:00")
        self.distanceRelay.accept("0.0m")
        self.locationRelay.accept("위치 파악중")
    }
    
    // 타이머 초기화
    private func invalidateTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    //MARK: - Realm DB 관련
    
    // Realm 객체
    private var trackData = TrackData()
    private var trackPoint = TrackPoint()
    
    // 다음 화면으로 넘어가기 허용 여부
    let shouldNextViewControllerAppear = BehaviorSubject<Bool>(value: false)
    
    // 경로 포인트 갯수 카운트
    private var count: Int = 0
    
    // 경로 거리 누적값 (m)
    private var distance: Double = 0.0 {
        didSet {
            var distanceString: String!
            
            if (..<1000) ~= self.distance {
                distanceString = String(format: "%.1f", self.distance) + "m"
                self.distanceRelay.accept(distanceString)
            } else {
                distanceString = String(format: "%.2f", self.distance/1000.0) + "km"
                self.distanceRelay.accept(distanceString)
            }
            
            // live widget에 표출할 시간 문자열 전달 및 업데이트
            LiveActivityService.shared.distanceString = distanceString
        }
    }
    
    // 형식을 갖춘 날짜 문자열
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분 ss초"
        return dateFormatter.string(from: Date())
    }
    
    // Realm DB에 경로 데이터 저장하기
    func createTrackData() {
        let dataToAppend = TrackData(
            points: self.trackData.points,
            date: self.dateString,
            time: self.timeString,
            distance: self.distance,
            name: "",
            explanation: "",
            feature: "",
            rating: 0.0)
        
        RealmService.shared.create(dataToAppend)
        
        self.shouldNextViewControllerAppear.onNext(true)
    }
    
    // 경로 데이터 배열 초기화
    func clearTrackDataArray() {
        self.trackData = TrackData()
        self.distance = 0.0
        self.count = 0
    }
    
    //MARK: - 지도 관련
    
    // 경로 거리 계산에 사용할 변수
    private var oldLatitude: Double = 0.0
    private var oldLongitude: Double = 0.0
    private var newLatitude: Double = 0.0
    private var newLongitude: Double = 0.0
    
    // 경로 추가 및 이동거리(현재 지점 <-> 이전 지점) 누적 계산
    func appendTrackPoint(currentLatitude: Double,
                          currentLongitude: Double) {
        // 신규 위치 추가
        let newTrackPoint = TrackPoint(
            latitude: currentLatitude,
            longitude: currentLongitude,
            id: ""
        )
        
        self.trackData.appendTrackPoint(point: newTrackPoint)
        
        if self.count == 0 {  // 사용자의 위치가 맨 처음 기록된 시점
            self.oldLatitude = currentLatitude
            self.oldLongitude = currentLongitude
        } else {
            self.newLatitude = newTrackPoint.latitude
            self.newLongitude = newTrackPoint.longitude

            // 이동거리 누적하기
            self.distance += (self.getDistanceBetweenTwoPoints(
                startLat: oldLatitude, startLon: oldLongitude,
                endLat: newLatitude, endLon: newLongitude
            ) as Double)

            // 현재 위치의 주소를 역지오코딩으로 가져오기
            let location = CLLocation(latitude: newLatitude, longitude: newLongitude)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                self.processResponse(withPlacemarks: placemarks, error: error)
            }
            
            // 다음번 거리 계산 시, 현재 위치의 값은 이전 위치의 값이 됨
            self.oldLatitude = self.newLatitude
            self.oldLongitude = self.newLongitude
        }
        
        self.count += 1
    }
    
    // 두 지점의 위도 및 경도를 받아서 거리를 계산
    private func getDistanceBetweenTwoPoints(startLat: Double, startLon: Double,
                                             endLat: Double, endLon: Double) -> CLLocationDistance {
        let startPoint = CLLocation(latitude: startLat, longitude: startLon)
        let endPoint = CLLocation(latitude: endLat, longitude: endLon)
        return endPoint.distance(from: startPoint)
    }
    
    // 역지오코딩 결과를 처리
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if error != nil {
            locationRelay.accept("위치 파악 불가")
        } else {
            if let placemarks = placemarks,
               let placemark = placemarks.first {
                locationRelay.accept(placemark.compactAddress)
            } else {
                locationRelay.accept("위치 파악 불가")
            }
        }
    }
    
    //MARK: - Action 관련
    
    // 즐겨찾기 데이터 초기화를 위한 Action 구성
    func getActionForStopTracking(viewController: UIViewController, mapView: MKMapView) {
        let alert = UIAlertController(
            title: "확인",
            message: "경로 생성을 중단할까요?\n지금까지 기록한 경로는 삭제됩니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "아니요", style: .default)
        )
        alert.addAction(
            UIAlertAction(title: "네", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                // 타이머 중단
                self.stopTimer()
                // 경로 데이터 초기화
                self.clearTrackDataArray()
                // 지도 위의 경로 표시 제거
                mapView.removeOverlays(mapView.overlays)
                // 잠금화면의 live activity 중단
                LiveActivityService.shared.deactivate()
                // navigation bar 숨기기 해제
                viewController.navigationController?.navigationBar.isHidden = false
                // 이전 화면으로 돌아가기
                viewController.navigationController?.popViewController(animated: true)
            }
        )
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
