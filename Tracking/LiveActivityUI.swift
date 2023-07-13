//
//  TrackingLiveActivity.swift
//  Tracking
//
//  Created by Eric on 2023/04/10.
//

import ActivityKit
import WidgetKit
import UIKit
import SwiftUI

// 다이내믹 아일랜드에서 보여줄 내용
struct DynamicIslandLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        
        ActivityConfiguration(for: TrackingAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "figure.walk")
                        .foregroundColor(Color.init(uiColor: K.Color.themeYellow))
                        .padding(.leading, 5)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("산책중")
                        .font(Font.system(.body).monospacedDigit())
                        .padding(.trailing, 5)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .center) {
                        Text("시간: " + context.state.time)
                            .monospacedDigit()
                        Text("거리: " + context.state.distance)
                            .monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    
                }
            } compactLeading: {
                VStack(alignment: .center) {
                    Image(systemName: "figure.walk")
                        .foregroundColor(Color.init(uiColor: K.Color.themeYellow))
                }
            } compactTrailing: {
                VStack(alignment: .center) {
                    Text("산책중")
                        .frame(alignment: .center)
                }
            } minimal: {
                Image(systemName: "figure.walk")
                    .foregroundColor(Color.init(uiColor: K.Color.themeYellow))
            }
        }
    }
}

// 잠금화면 위젯에서 보여줄 내용
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<TrackingAttributes>
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack(alignment: .center) {
                    Text("나만의 산책길을 만들고 있어요")
                        .fontWeight(.bold)
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
                HStack {
                    Spacer()
                    Label {
                        Text(context.state.time)
                            .monospacedDigit()
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                            .frame(width: 100)
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "timer")
                            .foregroundColor(Color.orange)
                    }
                    .font(.title3)
                    Spacer()
                    Label {
                        Text(context.state.distance)
                            .monospacedDigit()
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                            .frame(width: 100)
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                            .foregroundColor(Color.orange)
                    }
                    .font(.title3)
                    Spacer()
                }
                Spacer()
            }
            .frame(height: 100)
        }

    }
}
