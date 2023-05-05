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
    case marked, park, strollWay, recreationForest, tourSpot
}

enum MyPlaceSorting {
    case descendingByDate
    case ascendingByDate
    case descendingByTime
    case ascendingByTime
    case descendingByDistance
    case ascendingByDistance
    case descendingByRating
    case ascendingByRating
}
