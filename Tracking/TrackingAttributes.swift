//
//  TrackingAttributes.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/13.
//

import SwiftUI
import ActivityKit

// 잠금화면에 보여줄 데이터
struct TrackingAttributes: ActivityAttributes {
    //public typealias TrackingTimerData = ContentState
    
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties
        //var time: String
        //var distance: String
    }
    
    // Fixed non-changing properties
    var name: String
}
