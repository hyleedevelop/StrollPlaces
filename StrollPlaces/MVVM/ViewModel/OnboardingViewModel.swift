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
            OnboardingData(title: "내 주변의 산책할만한 장소 찾기",
                           description: "전국 1만 7천개 이상의\n산책할만한 장소를 찾아볼 수 있습니다.",
                           image: UIImage(imageLiteralResourceName: "demure-young-woman-walking")),
            OnboardingData(title: "산책길 관련 소식 보기",
                           description: "국내 산책길과 관련된 뉴스 기사들을\n한번에 확인할 수 있습니다.",
                           image: UIImage(imageLiteralResourceName: "demure-young-woman-walking")),
            OnboardingData(title: "나만의 산책길 만들어서 보관하기",
                           description: "기존에는 없던 나만의 산책길을\n새롭게 만들어 저장할 수 있습니다.",
                           image: UIImage(imageLiteralResourceName: "demure-young-woman-walking")),
        ]
    }
    
    //MARK: - directly called method
    
//    func getItem(at index: Int) -> OnboardingData {
//        return self.onboardingData[index]
//    }
    
}
