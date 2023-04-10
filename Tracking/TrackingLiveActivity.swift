//
//  TrackingLiveActivity.swift
//  Tracking
//
//  Created by Eric on 2023/04/10.
//

import ActivityKit
import WidgetKit
import SwiftUI

// 잠금화면에 보여줄 데이터
struct TrackingAttributes: ActivityAttributes {
    //public typealias TrackingTimerData = ContentState
    
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties
        var time: String
        var distance: String
    }
    
    // Fixed non-changing properties
    var name: String
}

// 잠금화면에서 보여줄 위젯
struct TrackingLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        
        ActivityConfiguration(for: TrackingAttributes.self) { context in
//            // Lock screen/banner UI goes here
//            VStack {
//                Text("나만의 산책길 만들기")
//                HStack {
//                    Button("시작") {
//                        print("경로 추적 시작")
//                    }
//                    Button("종료") {
//                        print("경로 추적 종료")
//                    }
//                }
//
//            }
//            .activityBackgroundTint(Color.black)
//            .activitySystemActionForegroundColor(Color.white)
            LockScreenLiveActivityView(context: context)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom")
                    // more content
                }
            } compactLeading: {
                
                Text("산책길")
            } compactTrailing: {
                Text("생성중")
//                let trackingViewModel = TrackingViewModel()
//                Text(trackingViewModel.timeString)
            } minimal: {
                Text("Min")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<TrackingAttributes>
    @AppStorage("trackingTime") var trackingTime: String!  // UserDefault 데이터 가져오기
    //@AppStorage("trackingTime", store: UserDefaults(suiteName: "trackingTime"))
    //let trackingTime = UserDefaults.standard.object(forKey: "trackingTime") as! String
    
    var body: some View {
        VStack {
            Spacer()
            Text("나만의 산책길을 만드는 중")
                .fontWeight(.bold)
                .font(.title2)
                .foregroundColor(.white)
            Spacer()
            HStack {
                Spacer()
                Label {
                    //Text(trackingTime)
                    Text("00:12:34")
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                        .foregroundColor(.white)
                } icon: {
                    Image(systemName: "timer")
                        .foregroundColor(.red)
                }
                .font(.title3)
                Spacer()
                Label {
                    Text("937 m")
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                        .foregroundColor(.white)
                } icon: {
                    Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                        .foregroundColor(.red)
                }
                .font(.title3)
                Spacer()
            }
            Spacer()
        }
        .frame(height: 100)
        //.tint(.white)
        //.foregroundColor(.black)
        .activitySystemActionForegroundColor(.white)
        .activityBackgroundTint(.black)
        
    }
}

//struct TrackingLiveActivity_Previews: PreviewProvider {
//    static let attributes = TrackingAttributes(name: "새로운 나만의 산책길")
//    static let contentState = TrackingAttributes.ContentState(time: "00:00:00", distance: "0 m")
//
//    static var previews: some View {
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
//            .previewDisplayName("Island Compact")
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
//            .previewDisplayName("Island Expanded")
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
//            .previewDisplayName("Minimal")
//        attributes
//            .previewContext(contentState, viewKind: .content)
//            .previewDisplayName("Notification")
//    }
//}
