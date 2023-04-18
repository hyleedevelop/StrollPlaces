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
