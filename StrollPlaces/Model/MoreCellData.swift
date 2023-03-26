//
//  SettingCellData.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/14.
//

import UIKit

enum MoreCellData {
    case appSettings([AppSettingsModel])
    case feedback([FeedbackModel])
    case aboutTheApp([AboutTheAppModel])
}

struct AppSettingsModel {
    let icon: UIImage?
    let title: String?
    var value: String?
}

struct FeedbackModel {
    let icon: UIImage?
    let title: String?
    var value: String?
}

struct AboutTheAppModel {
    let icon: UIImage?
    let title: String?
    var value: String?
}
