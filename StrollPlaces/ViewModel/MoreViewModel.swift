//
//  SettingViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/14.
//

import UIKit
import RxSwift
import RxCocoa

final class MoreViewModel {
    
    private var appSettingsModel = [
        AppSettingsModel(icon: UIImage(systemName: "paintbrush"), title: "Theme Color", value: nil),
    ]

    private var feedbackModel = [
        FeedbackModel(icon: UIImage(systemName: "star"), title: "Rate The App", value: nil),
        FeedbackModel(icon: UIImage(systemName: "envelope"), title: "Contact", value: nil),
    ]

    private var aboutTheAppModel = [
        AboutTheAppModel(icon: UIImage(systemName: "questionmark.circle"), title: "Help", value: nil),
        AboutTheAppModel(icon: UIImage(systemName: "wand.and.stars.inverse"), title: "Third-Party Libraries", value: nil),
        AboutTheAppModel(icon: UIImage(systemName: "doc.text"), title: "Privacy Policy", value: nil),
        AboutTheAppModel(icon: UIImage(systemName: "doc.text"), title: "Terms & Conditions", value: nil),
        AboutTheAppModel(icon: UIImage(systemName: "c.circle"), title: "Copyright", value: "HOYEON LEE"),
        AboutTheAppModel(icon: UIImage(systemName: "number.circle"), title: "App Version", value: nil),
    ]

    //MARK: - 메서드 정의

    func appSettingData() -> MoreCellData {
        return MoreCellData.appSettings(appSettingsModel)
    }

    func feedbackData() -> MoreCellData {
        return MoreCellData.feedback(feedbackModel)
    }

    func aboutTheAppData() -> MoreCellData {
        return MoreCellData.aboutTheApp(aboutTheAppModel)
    }

    func updateAboutTheAppData(index: Int, newValue: String?) {
        guard let newValue = newValue else { return }
        aboutTheAppModel[index].value = newValue
    }
    
}



