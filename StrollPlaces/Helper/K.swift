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
    struct CSV {
        static let parkData: String = "SouthKoreaParkData_qc_20230312"
        static let strollWayData: String = "SouthKoreaStrollWayData_qc_20230312"
        static let recreationForestData: String = "SouthKoreaRecreationForestData_qc_20230312"
        static let tourSpotData: String = "SouthKoreaTourSpotData_qc_20230312"
    }
    
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
    
        static let noDataMessage: String = "정보없음"
        
        static var themeColor: [UIColor] = [#colorLiteral(red: 0.2846682966, green: 0.3880401254, blue: 0.336489141, alpha: 1), #colorLiteral(red: 0.3058823529, green: 0.4235294118, blue: 0.3137254902, alpha: 1), #colorLiteral(red: 0.6666666667, green: 0.5450980392, blue: 0.337254902, alpha: 1), #colorLiteral(red: 0.9411764706, green: 0.9215686275, blue: 0.8078431373, alpha: 1)]
    }
    
    // CollectionView 관련
    struct ThemeCV {
        static let cellName: String = "ThemeCollectionViewCell"
        static let spacingWidth: CGFloat = 5
        static let spacingHeight: CGFloat = 0
        static let leadingSpacing: CGFloat = (spacingWidth + spacingHeight) * 2
        static let trailingSpacing: CGFloat = (spacingWidth + spacingHeight) * 2
        static let cellColumns: CGFloat = 3
        static let cellWidth: CGFloat = (UIScreen.main.bounds.width - (leadingSpacing + trailingSpacing) - spacingWidth * (cellColumns - 1)) / cellColumns
        static let cellHeight: CGFloat = 35
    }
    
    // DetailView 관련
    struct DetailView {
        static let slideViewHeight: CGFloat = 300
        static let cornerRadiusOfSlideView: CGFloat = 20
        static let animationTime: CGFloat = 0.3
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
