//
//  Constant.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import CoreLocation

struct K {
    // CSV 파일 관련
    static let parkCSV: String = "SouthKoreaParkData_qc_20230312"
    static let walkingStreetCSV: String = "SouthKoreaWalkingStreetData_qc_20230312"
    static let tourSpotCSV: String = "SouthKoreaTourSpotData_qc_20230312"
    
    static let parkURL: String =
    "http://api.data.go.kr/openapi/tn_pubr_public_cty_park_info_api" +
    "?serviceKey=0cTu6h50N7kXJjKS32%2B%2FWwpVe4PvV%2FyNSrM6UlxNM7wi8RwY9y7YJzCPDnm47NWEaeo7mRB5z06vbNPIQ3qV0Q%3D%3D" +
    "&pageNo=0&numOfRows=100&type=xml"
    
    static let streetURL: String = ""
    
    // Mapkit, CoreLocation 관련
    struct Map {
        static let defaultLatitude: Double = 37.88604
        static let defaultLongitude: Double = 127.7454
        static let southKoreaCenterLatitude: Double = 36.34
        static let southKoreaCenterLongitude: Double = 127.77
        
        static let initialLocation = CLLocation(latitude: K.Map.defaultLatitude,
                                                longitude: K.Map.defaultLongitude)
        static let southKoreaCenterLocation = CLLocation(latitude: southKoreaCenterLatitude,
                                                         longitude: southKoreaCenterLongitude)
        static let seoulLocation = CLLocation(latitude: 37.535545, longitude: 126.983683)
    }
    
    // CollectionView 관련
    struct ThemeCV {
        static let cellName: String = "ThemeCollectionViewCell"
        static let spacingWidth: CGFloat = 0
        static let spacingHeight: CGFloat = 0
        static let leadingSpacing: CGFloat = (spacingWidth + spacingHeight) * 2
        static let trailingSpacing: CGFloat = (spacingWidth + spacingHeight) * 2
        static let cellColumns: CGFloat = 3
        static let cellWidth: CGFloat = (UIScreen.main.bounds.width - (leadingSpacing + trailingSpacing) - spacingWidth * (cellColumns - 1)) / cellColumns
        static let cellHeight: CGFloat = 34
    }
    
    // 메세지 관련
    struct Message {
        static let errorTitle = "Error"
        
        static let resetMessage = "Are you sure you want to reset all input?"
        static let exportAsImageMessage = "Do you want to export the result as an image?"
        static let sendEmailErrorMessage = "Check your e-mail settings."
        static let notifyLaterUpdate = "This will be updated soon."
    }
}
