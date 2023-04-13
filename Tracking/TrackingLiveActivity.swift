//
//  TrackingLiveActivity.swift
//  Tracking
//
//  Created by Eric on 2023/04/10.
//

import ActivityKit
import WidgetKit
import SwiftUI

// TrackingViewModel에서 받아와 화면에 표출할 데이터
class WidgetData: ObservableObject {
    @Published var time: String = ""
    @Published var distance: String = ""
}

// 잠금화면에서 보여줄 위젯
struct TrackingLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TrackingAttributes.self) { context in
            LockScreenLiveActivityView()
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
    //let context: ActivityViewContext<TrackingAttributes>
    //@AppStorage("trackingTime") var trackingTime: String!  // UserDefault 데이터 가져오기
    //@EnvironmentObject var widgetData: WidgetData
    @ObservedObject var widgetData = WidgetData()
    
    var body: some View {
        ZStack {
            
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
                        Text(widgetData.time)
                        //Text("12분 34초")
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
                        Text("537.1m")
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
            .background(.black)
            
            
        }

    }
}

//struct LockScreenLiveActivityView_Previews: PreviewProvider {
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
