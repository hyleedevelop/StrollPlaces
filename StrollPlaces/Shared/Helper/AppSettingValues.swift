//
//  AppSetting.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/14.
//

import UIKit
import MapKit

//MARK: - class

final class AppSettingValues {
    
    static let shared = AppSettingValues()
    private init() {}
    
    var navigationMode: MKDirectionsTransportType = .automobile
    
}

//MARK: - enum


