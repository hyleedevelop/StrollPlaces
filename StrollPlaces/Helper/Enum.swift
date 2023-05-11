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
    //case marked
    case park
    case strollWay
    case recreationForest
    case tourSpot
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
