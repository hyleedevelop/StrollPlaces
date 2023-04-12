//
//  CLPlacemark.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/12.
//

import Foundation
import CoreLocation

extension CLPlacemark {

    var compactAddress: String {
        var result = ""
        
        if let area = self.administrativeArea {
            result += " \(area)"
        }
        
        if let city = self.locality {
            result += " \(city)"
        }
        
//        if let street = self.thoroughfare {
//            print("street: ", street)
//            result += " \(street)"
//        }
        
        if let name = self.name {
            result += " \(name)"
        }
        
        return result
    }

}
