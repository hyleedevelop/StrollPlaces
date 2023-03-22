//
//  AppSetting.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/14.
//

import UIKit
import MapKit

//MARK: - class

final class AppSetting {
    
    static let shared = AppSetting()
    private init() {}
    
    var navigationMode: MKDirectionsTransportType = .walking
    
}

//MARK: - enum


