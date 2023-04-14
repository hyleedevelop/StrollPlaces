//
//  LiveActivityService.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/10.
//

// ⭐️ StrollPlaces와 TrackingExtension에서 모두 접근 가능한 싱글톤 객체

import SwiftUI
import ActivityKit

final class LiveActivityService: ObservableObject {

    static let shared = LiveActivityService()
    @Published var activity: Activity<TrackingAttributes>?
    
    private init() {}

    var timeString: String = ""
    var distanceString: String = ""
    
    func activate() {
        guard activity == nil else { return }
        
        let attributes = TrackingAttributes(name: "new track")
        let state = TrackingAttributes.TrackingStatus(time: "00:00:00", distance: "0.0m")
        
        do {
            let activity = try Activity<TrackingAttributes>.request(
                attributes: attributes,
                contentState: state,
                pushType: nil
            )
            print(activity)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func update() {
        Task {
            let state = TrackingAttributes.TrackingStatus(time: self.timeString, distance: self.distanceString)
            for activity in Activity<TrackingAttributes>.activities {
                await activity.update(using: state)
            }
        }
    }
    
    func deactivate() {
        Task {
            for activity in Activity<TrackingAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }

}
