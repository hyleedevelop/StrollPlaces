//
//  Constant.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import CoreLocation

struct K {
    struct Color {
        static let transparentOrange = #colorLiteral(red: 0.9921568627, green: 0.9568627451, blue: 0.8941176471, alpha: 1)
        static let transparentGreen = #colorLiteral(red: 0.9333333333, green: 0.9647058824, blue: 0.8980392157, alpha: 1)
        static let transparentPurple = #colorLiteral(red: 0.8156862745, green: 0.8, blue: 0.9294117647, alpha: 1)
        
        static let lightOrange = #colorLiteral(red: 0.9568627451, green: 0.6431372549, blue: 0.2666666667, alpha: 1)
        static let lightGreen = #colorLiteral(red: 0.5764705882, green: 0.7568627451, blue: 0.431372549, alpha: 1)
        static let lightPurple = #colorLiteral(red: 0.3725490196, green: 0.3333333333, blue: 0.6823529412, alpha: 1)
        
        static let darkGray = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        static let mainColor = #colorLiteral(red: 0.1647058824, green: 0.6549019608, blue: 0.4588235294, alpha: 1)
    }
    
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
        
        static var themeColor: [UIColor] = [#colorLiteral(red: 0.2846682966, green: 0.3880401254, blue: 0.336489141, alpha: 1), #colorLiteral(red: 0.3058823529, green: 0.4235294118, blue: 0.3137254902, alpha: 1), #colorLiteral(red: 0.7137254902, green: 0.6392156863, blue: 0.4509803922, alpha: 1), #colorLiteral(red: 0.9411764706, green: 0.9215686275, blue: 0.8078431373, alpha: 1)]
    }
    
    // Theme CollectionView 관련
    struct ThemeCV {
        static let cellName: String = "ThemeCollectionViewCell"
        static let spacingWidth: CGFloat = 5
        static let spacingHeight: CGFloat = 0
        static let leadingSpacing: CGFloat = (spacingWidth + spacingHeight) * 2
        static let trailingSpacing: CGFloat = (spacingWidth + spacingHeight) * 2
        static let cellColumns: CGFloat = 3
        static let cellWidth: CGFloat = (UIScreen.main.bounds.width - (leadingSpacing + trailingSpacing) - spacingWidth * (cellColumns - 1)) / cellColumns
        static let cellHeight: CGFloat = 40
    }

    // News TableView 관련
    struct News {
        static let naverClientID = "wWtKBkZLX3epsO5GoY2I"
        static let naverClientKEY = "OPGXmkEsDn"
        static let keyword = "산책길"
        static let cellName: String = "NewsTableViewCell"
    }
    
    // DetailView 관련
    struct DetailView {
        static let slideViewHeight: CGFloat = 300
        static let cornerRadiusOfSlideView: CGFloat = 20
        static let animationTime: CGFloat = 0.3
        static let detailButtonName = "상세정보 보기"
        static let navigateButtonName = "경로 보기"
        static let bookmarkButtonName = "즐겨찾기 등록"
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
