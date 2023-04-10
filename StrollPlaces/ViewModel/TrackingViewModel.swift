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

final class TrackingViewModel: ObservableObject {
    
    //MARK: - property
    
    private var hours: Int = 0
    private var minutes: Int = 0
    private var seconds: Int = 0
    private var timer: Timer? = nil
    
    var trackData = TrackData()
    var id: String = ""
    var timeString: String = ""
    
    var timeRelay = BehaviorRelay<String>(value: "00:00:00")
    var distanceRelay = BehaviorRelay<String>(value: "0 m")
    var locationRelay = BehaviorRelay<String>(value: "위치 측정 중")
    
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
            
            self.timeString = String(format: "%02i:%02i:%02i", self.hours, self.minutes, self.seconds)
            self.timeRelay.accept(self.timeString)
            UserDefaults.standard.set(self.timeString, forKey: "trackingTime")
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
        
        self.timeRelay.accept(
            String(format: "%02i:%02i:%02i", self.hours, self.minutes, self.seconds)
        )
    }
    
    // Realm DB에 경로 데이터 저장하기
    func createTrackData() {
        let dataToAppend = TrackData(
            points: self.trackData.points,
            date: Date(),
            time: self.timeString,
            distance: 0.0,
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
    }
    
    // 경로 추가
    func appendTrackPoint(newTrackPoint: TrackPoint) {
        self.trackData.appendTrackPoint(point: newTrackPoint)
    }
    
    //MARK: - indirectly called method
    
    // 타이머 초기화
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}
