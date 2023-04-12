//
//  CountDownView.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/12.
//

import SwiftUI
import RxSwift

struct CountdownView: View {
    @Binding var countdown: CGFloat
    
    var body: some View {
        ZStack {
            if countdown >= 0.0 {
                Text("\(String(format: "%.0f", abs(min(3, ceil(countdown + 0.01))) ))")
                    .font(Font.system(.largeTitle).monospacedDigit())
                    .foregroundColor(Color(.white))
            } else {
                Text("시작!")
                    .font(Font.system(.largeTitle).monospacedDigit())
                    .foregroundColor(Color(.white))
            }
            Circle()
                .stroke(lineWidth: 15)
                .foregroundColor(Color(.darkGray))
                .padding(5)
            Circle()
                .trim(from: 0, to: countdown / 3.0)
                .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                .rotation(Angle(degrees: 90))
                .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .foregroundColor(Color(.green))
                .padding(5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.black))
    }
}

struct AnimatedCountdownView: View {
    @State var countdown: CGFloat = 3
    var countdownValue = PublishSubject<CGFloat>()
    
    let timer = Timer.TimerPublisher(interval: 1.0, runLoop: .main, mode: .common)
        .autoconnect()
        .prefix(4)
    
    var body: some View {
        CountdownView(countdown: $countdown)
            .onReceive(timer) { _ in
                withAnimation(.timingCurve(0.23, 0.97, 0.08, 0.97, duration: 1.0)) {
                //withAnimation(.linear(duration: 1.0)) {
                //withAnimation(.default) {
                    
                    // 카운트다운 값을 TrackingViewController로 전달
                    self.countdownValue.onNext(countdown)
                    countdown -= 1.0
                }
            }
    }
}

struct CountDownView_Previews: PreviewProvider {
//    static var previews: some View {
//        CountdownView(countdown: .constant(3.0))
//    }
    
    static var previews: some View {
        AnimatedCountdownView()
    }
}
