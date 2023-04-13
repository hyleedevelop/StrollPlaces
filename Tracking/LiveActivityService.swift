//
//  LiveActivityService.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/10.
//

import SwiftUI
import ActivityKit

final class LiveActivityService: ObservableObject {

    static let shared = LiveActivityService()
    @Published var activity: Activity<TrackingAttributes>?
    
    private init() {}

    func start() {
        guard activity == nil else { return }
        
        let attributes = TrackingAttributes(name: "새로운 나만의 산책길")
        let contentState = TrackingAttributes.ContentState()
        
        do {
            let activity = try Activity<TrackingAttributes>.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            print(activity)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func update(state: TrackingAttributes.ContentState) {
        //let timeString = "0초"
        //let distanceString = "0.0m"
        Task {
            let updateContentState = TrackingAttributes.ContentState()
            for activity in Activity<TrackingAttributes>.activities {
                await activity.update(using: updateContentState)
            }
        }
    }
    
    func stop() {
        Task {
            for activity in Activity<TrackingAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }

}
