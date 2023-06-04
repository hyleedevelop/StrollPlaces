//
//  OnboardingViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/09.
//

import UIKit

final class OnboardingViewModel {
    
    //MARK: - normal property
    
    let slide: [OnboardingData]!
    
    //MARK: - initializer
    
    init() {
        self.slide = [
            OnboardingData(title: "가볍게 산책할만한 장소 찾기",
                           description: "전국 약 17,000곳 이상의\n가볍게 산책하기 좋은 장소를 찾아보세요!",
                           image: UIImage(imageLiteralResourceName: "onboarding_image_1")),
            OnboardingData(title: "산책길 관련 소식 모아보기",
                           description: "산책길과 관련된 다양한 소식을\n뉴스 기사를 통해 확인해보세요!",
                           image: UIImage(imageLiteralResourceName: "onboarding_image_2")),
            OnboardingData(title: "나만의 산책길 만들기",
                           description: "기존에는 없던 나만의 산책길을\n직접 걸으면서 새롭게 만들어보세요!",
                           image: UIImage(imageLiteralResourceName: "onboarding_image_3")),
        ]
    }
    
    //MARK: - directly called method
    
//    func getItem(at index: Int) -> OnboardingData {
//        return self.onboardingData[index]
//    }
    
}
