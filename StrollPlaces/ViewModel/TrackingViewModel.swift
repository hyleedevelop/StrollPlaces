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

final class TrackingViewModel {
    
    //MARK: - property
    
    private var hours: Int = 0
    private var minutes: Int = 0
    private var seconds: Int = 0
    private var timer: Timer? = nil
    
    var trackData = TrackData()
    
    var timeRelay = BehaviorRelay<String>(value: "00:00:00")
    var distanceRelay = BehaviorRelay<String>(value: "0m")
    var locationRelay = BehaviorRelay<String>(value: "위치 측정 중")
    
    //MARK: - initializer
    
    
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
            
            let timeString = String(format: "%02i:%02i:%02i", self.hours, self.minutes, self.seconds)
            self.timeRelay.accept(timeString)
            self.trackData.time = timeString
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
        // 경로 저장 날짜 = 현재 날짜
        self.trackData.date = Date()
        //self.trackData.time = ""
        self.trackData.distance = ""
        self.trackData.firstLocation = ""
        self.trackData.name = ""
        self.trackData.explanation = ""
        self.trackData.feature = ""
        //self.trackData.image = UIImage()
        
        RealmService.shared.create(self.trackData)
    }
    
    // trackData 배열 초기화
    func clearTrackDataArray() {
        self.trackData = TrackData()
    }
    
    //MARK: - indirectly called method
    
    // 타이머 초기화
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}
