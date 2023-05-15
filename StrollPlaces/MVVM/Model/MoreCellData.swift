//
//  SettingCellData.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/14.
//

import UIKit

enum MoreCellSection: Int, CaseIterable {
    case appSettings = 0
    case feedback
    case aboutTheApp
}

struct MoreCellData {
    let title: String?
    var value: String?
}
