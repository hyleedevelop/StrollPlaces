//
//  Enum.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/16.
//

import Foundation

enum Selection: Int {
    case count, imageCount, image
}

enum InfoType: Int, CaseIterable {
    case marked, park, strollWay, recreationForest, tourSpot
}

