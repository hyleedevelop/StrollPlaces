//
//  Double.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import Foundation

extension Double {
    
    var m: Double {
        return self
    }
    
    var km: Double {
        return (self * 1000)
    }
    
    var minute: Double {
        return (self / 60.0)
    }
    
}
