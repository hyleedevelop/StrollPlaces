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
        static let themeBlack: UIColor = #colorLiteral(red: 0.1450980392, green: 0.1568627451, blue: 0.2039215686, alpha: 1)
        static let themeGray: UIColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
        static let themeNavy: UIColor = #colorLiteral(red: 0.3005333543, green: 0.357681036, blue: 0.5561813116, alpha: 1)
        static let themeYellow: UIColor = #colorLiteral(red: 0.9882352941, green: 0.6156862745, blue: 0.1764705882, alpha: 1)
        static let themePurple: UIColor = #colorLiteral(red: 0.4682491422, green: 0.3311958313, blue: 0.8449422717, alpha: 1)
        static let themeWhite: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static let backgroundGray: UIColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        
        //static let themeYellow: Color
        
        static let mainColor = #colorLiteral(red: 0.4682491422, green: 0.3311958313, blue: 0.8449422717, alpha: 1)
        static let mainColorLight = #colorLiteral(red: 0.7411764706, green: 0.6705882353, blue: 0.9215686275, alpha: 1)
    }
    
    struct Shape {
        static let smallCornerRadius: CGFloat = 2
        static let mediumCornerRadius: CGFloat = 5
        static let largeCornerRadius: CGFloat = 25
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

    // DetailView 관련
    struct DetailView {
        static let slideViewHeight: CGFloat = 300
        static let cornerRadiusOfSlideView: CGFloat = 20
        static let animationTime: CGFloat = 0.3
        static let detailButtonName = "상세정보 보기"
        static let navigateButtonName = "경로 보기"
        static let bookmarkButtonName = "즐겨찾기 등록"
    }
    
    // MY플레이스 관련
    struct MyPlace {
        static let cellName: String = "MyPlaceCollectionViewCell"
        static let spacingWidth: CGFloat = 15
        static let spacingHeight: CGFloat = 15
        static let leadingSpacing: CGFloat = 15
        static let trailingSpacing: CGFloat = 15
        static let cellColumns: CGFloat = 2
        static let cellWidth: CGFloat = (UIScreen.main.bounds.width - (leadingSpacing + trailingSpacing) - spacingWidth * (cellColumns - 1)) / cellColumns
        static let cellHeight: CGFloat = 290
    }
    
    // News TableView 관련
    struct News {
        static let naverClientID = "wWtKBkZLX3epsO5GoY2I"
        static let naverClientKEY = "OPGXmkEsDn"
        static let keyword = "산책길"
        static let cellName: String = "NewsTableViewCell"
    }
    
    // 메세지 관련
    struct Message {
        static let errorTitle = "Error"
        static let resetMessage = "Are you sure you want to reset all input?"
        static let exportAsImageMessage = "Do you want to export the result as an image?"
        static let sendEmailErrorMessage = "Check your e-mail settings."
        static let notifyLaterUpdate = "This will be updated soon."
    }
    
    // 더보기 탭 관련
    struct More {
        static let appSettingsTitle = "설정"
        static let feedbackTitle = "피드백"
        static let aboutTheAppTitle = "정보"
        
        static let helpURL =
        "https://hyleenote.notion.site/Crypto-Calculator-5f6ae38726dd400c8b3a91a24da06795"
        static let privacyPolicyURL =
        "https://hyleenote.notion.site/Privacy-Policy-98bd35e6626c4accbd609616553b071e"
        static let termsAndConditionsURL =
        "https://hyleenote.notion.site/Terms-Conditions-037cf1cf478f4925bdc69f5404091242"
        static let writeReviewURL =
        "https://apps.apple.com/app/id1668703292?action=write-review"
        
        static let sorryTitle = "죄송합니다."
        static let notifyLaterUpdateMessage = "곧 업데이트 예정입니다."
    }
}
