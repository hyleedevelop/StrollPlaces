//
//  MapViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import MapKit
//import RealmSwift

final class MapViewModel {
    
    private var parkData = [Park]()
    //private var walkingStreetData = [WalkingStreet]()
    //private var tourSpotData = [TourSpot]()
    
    
    //MARK: - 공원 정보 관련
    
    /* ViewController에게 공원 정보 넘겨주기 */
    func getParkInfo() -> [Park] {
        // CSV 파일 위치 가져오기
        guard let path = Bundle.main.path(forResource: K.parkCSV, ofType: "csv") else {
            fatalError("[ERROR] Unable to find the path of csv file")
        }

        // CVS 파일에서 데이터 가져오기
        guard let dataArray = fetchFromCSV(url: URL(fileURLWithPath: path)) else {
            fatalError("[ERROR] Unable to fetch csv file")
        }
        
        // 데이터를 Park 구조체에 넣기
        for index in 1..<dataArray.count-1 {
            if let lat = Double(dataArray[index][5]),
               let lon = Double(dataArray[index][6]) {
                parkData.append(
                    Park(name: dataArray[index][1], lat: lat, lon: lon, telephoneNumber: "123-456")
                )
            }
        }
        
        return parkData
    }
    
    //MARK: - 산책로 정보 관련
    
//    func getWalkingStreetInfo() -> [WalkingStreet] {
//        // CSV 파일 위치 가져오기
//        guard let path = Bundle.main.path(forResource: K.walkingStreetCSV, ofType: "csv") else {
//            fatalError("[ERROR] Unable to find the path of csv file")
//        }
//
//        // CVS 파일에서 데이터 가져오기
//        guard let dataArray = fetchFromCSV(url: URL(fileURLWithPath: path)) else {
//            fatalError("[ERROR] Unable to fetch csv file")
//        }
//
//        // 데이터를 WalkingStreet 구조체에 넣기
//        for index in 1..<dataArray.count-1 {
//            if let lat = Double(dataArray[index][14]),
//               let lon = Double(dataArray[index][15]) {
//                walkingStreetData.append(
//                    WalkingStreet(name: dataArray[index][1], subName: dataArray[index][2], lat: lat, lon: lon)
//                )
//            }
//        }
//
//        return walkingStreetData
//    }
    
    //MARK: - 지역명소 정보 관련
    
//    func getTourSpotInfo() -> [TourSpot] {
//        return
//    }
    
    
    //MARK: - CSV 읽어오기
    
    /* 공원 정보 CSV 파일 로드 및 parsing 수행 */
    private func fetchFromCSV(url: URL) -> [[String]]? {
        do {
            let data = try Data(contentsOf: url)
            let dataEncoded = String(data: data, encoding: .utf8)
            
            if let dataArray = dataEncoded?.components(separatedBy: "\n").map({$0.components(separatedBy: ",")}) {
                return dataArray
            } else {
                return nil
            }
        } catch {
            print("[ERROR] Unable to load csv file")
            return nil
        }
    }
    
    //MARK: - UICollectionView 관련
    
    let themeCellViewModel: [ThemeCellViewModel]
    
    init(_ themeCellViewModel: [ThemeCellData]) {
        //self.articleVM = articleVM
        self.themeCellViewModel = themeCellViewModel.compactMap(ThemeCellViewModel.init)
    }
    
    func cellData(at index: Int) -> ThemeCellViewModel {
        return self.themeCellViewModel[index]
    }
    
}

