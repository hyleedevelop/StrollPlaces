//
//  Enum.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/16.
//

import UIKit

enum Selection: Int {
    case count, imageCount, image
}

enum InfoType: Int, CaseIterable {
    case park = 0
    case strollWay
    case recreationForest
    case marked
}

enum MyPlaceSorting: Int {
    case ascendingByDate = 0
    case descendingByDate
    case ascendingByTime
    case descendingByTime
    case ascendingByDistance
    case descendingByDistance
    case ascendingByRating
    case descendingByRating
}

enum EditableItems {
    case name
    case explanation
    case feature
}

enum DateFormatType {
    case myPlace
    case news
}

enum MoreCellSection: Int, CaseIterable {
    case appSettings = 0
    case feedback
    case aboutTheApp
}

enum LoginType {
    case google
    case apple
}

enum UserInfoType {
    case name
    case email
}

enum SignupOrLogin {
    case signup
    case login
}

enum MapType: Int, CaseIterable {
    case standard = 0
    case satellite = 1
    case hybrid = 2
}
