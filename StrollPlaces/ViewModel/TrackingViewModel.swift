//
//  TrackingViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/02.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import CoreLocation
import SwiftUI
//import WidgetKit

final class TrackingViewModel: ObservableObject {
    
    //MARK: - property
    
    private var hours: Int = 0
    private var minutes: Int = 0
    private var seconds: Int = 0
    private var timer: Timer? = nil
    
    var trackData = TrackData()
    var trackPoint = TrackPoint()
    var timeString: String = ""
    
    // 경로 포인트 카운트
    private var count: Int = 0
    // 경로 거리 누적값 (m)
    private var distance: Double = 0.0 {
        didSet {
            if (..<1000) ~= self.distance {
                self.distanceRelay.accept(
                    String(format: "%.1f", self.distance) + "m"
                )
            } else {
                self.distanceRelay.accept(
                    String(format: "%.2f", self.distance/1000.0) + "km"
                )
            }
        }
    }
    private var oldLatitude: Double = 0.0
    private var oldLongitude: Double = 0.0
    private var newLatitude: Double = 0.0
    private var newLongitude: Double = 0.0
    
    // SwiftUI에서도 사용할 변수들
    var timeRelay = BehaviorRelay<String>(value: "0초")
    var distanceRelay = BehaviorRelay<String>(value: "0.0m")
    var locationRelay = BehaviorRelay<String>(value: "-")
    
    @Published var timeSubject = BehaviorSubject<String>(value: "0초")
    
    //MARK: - initializer
    
    init() {
        
    }
    
    //MARK: - directly called method
    
    // 타이머 시작
    func startTimer() {
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
            
            // 화면에 표출할 시간 문자열 설정
            if self.hours == 0 {
                if self.minutes == 0 {
                    // 0시간 0분 x초
                    self.timeString = "\(self.seconds)초"
                } else {
                    // 0시간 x분 x초
                    self.timeString = "\(self.minutes)분 \(self.seconds)초"
                }
            } else {
                // x시간 x분 x초
                self.timeString = "\(self.hours)시간 \(self.minutes)분 \(self.seconds)초"
            }
            
            let widgetData = WidgetData()
            widgetData.time = self.timeString
            let activityView = LockScreenLiveActivityView()
            let VC = UIHostingController(rootView: activityView.environmentObject(widgetData))
            
            
            
            // label text 바인딩을 위한 시간 문자열 방출
            self.timeRelay.accept(self.timeString)
            //UserDefaults.standard.set(self.timeString, forKey: "trackingTime")
        }
    }
    
    // 타이머 일시정지
    func pauseTimer() {
        invalidateTimer()
    }
    
    // 타이머 중단
    func stopTimer() {
        invalidateTimer()
        
        self.seconds = 0
        self.minutes = 0
        self.hours = 0
        
        self.timeRelay.accept("0초")
        self.distanceRelay.accept("0.0m")
        self.locationRelay.accept("-")
    }
    
    // Realm DB에 경로 데이터 저장하기
    func createTrackData() {
        let dataToAppend = TrackData(
            points: self.trackData.points,
            date: Date(),
            time: self.timeString,
            distance: self.distance,
            firstLocation: nil,
            lastLocation: nil,
            name: nil,
            explanation: nil,
            feature: nil)
        
        print(self.trackData.points)
        RealmService.shared.create(dataToAppend)
    }
    
    // 경로 데이터 배열 초기화
    func clearTrackDataArray() {
        self.trackData = TrackData()
        self.distance = 0.0
        self.count = 0
    }
    
    // 경로 추가 및 이동거리(현재 지점 <-> 이전 지점) 누적 계산
    func appendTrackPoint(newTrackPoint: TrackPoint,
                          currentLatitude: Double,
                          currentLongitude: Double) {
        // 신규 위치 추가
        self.trackData.appendTrackPoint(point: newTrackPoint)
        
        if self.count == 0 {  // 사용자의 위치가 처음 기록되었을 때
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
    
    //MARK: - indirectly called method
    
    // 타이머 초기화
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 두 지점의 위도 및 경도를 받아서 거리를 계산
    private func getDistanceBetweenTwoPoints(
        startLat: Double, startLon: Double, endLat: Double, endLon: Double
    ) -> CLLocationDistance {
        let startPoint = CLLocation(latitude: startLat, longitude: startLon)
        let endPoint = CLLocation(latitude: endLat, longitude: endLon)
        return endPoint.distance(from: startPoint)
    }
    
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
    
}
