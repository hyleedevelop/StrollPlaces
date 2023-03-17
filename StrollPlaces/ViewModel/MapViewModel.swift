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
    
    private var publicData = [PublicData]()
    //private var walkingStreetData = [WalkingStreet]()
    //private var tourSpotData = [TourSpot]()
    
    
    //MARK: - 공원 정보 관련
    
    func getPublicData() -> [PublicData] {
        loadParkData()
        //loadStrollWayData()
        //loadTourSpotData()
        return publicData
    }
    
    /* ViewController에게 공원 정보 넘겨주기 */
    private func loadParkData() {
        // CSV 파일 위치 가져오기
        guard let path = Bundle.main.path(forResource: K.parkCSV, ofType: "csv") else {
            fatalError("[ERROR] Unable to find the path of csv file")
        }

        // CVS 파일에서 데이터 가져오기
        guard let dataArray = fetchFromCSV(url: URL(fileURLWithPath: path)) else {
            fatalError("[ERROR] Unable to fetch csv file")
        }
        
        // 데이터를 Park 구조체에 넣기
        for index in 1..<dataArray.count-1 {  // index = 0은 제목에 해당하므로 제외
            if let latitude = Double(dataArray[index][5]),
               let longitude = Double(dataArray[index][6]) {
                
                // 이름
                let name: String = dataArray[index][1].count != 0 ? dataArray[index][1] : K.Map.noDataMessage
                // 카테고리
                let category: String = dataArray[index][2].count != 0 ? dataArray[index][2] : K.Map.noDataMessage
                // 주소(도로명주소 우선, 없을 시 지번주소, 둘다 없을 시 정보 없음)
                var address: String {
                    if (dataArray[index][3].count + dataArray[index][4].count) == 0 {
                        return K.Map.noDataMessage
                    } else {
                        return dataArray[index][3].count != 0 ? dataArray[index][3] : dataArray[index][4]
                    }
                }
                // 주변시설
                #warning("코드 구현 필요")
                var infra: String {
                    let mergedString = dataArray[index][8]
                    return K.Map.noDataMessage
                }
                // 관리기관
                let organization: String = dataArray[index][14].count != 0 ? dataArray[index][14] : K.Map.noDataMessage
                // 관리기관 전화번호
                let telephoneNumber: String = dataArray[index][15].count != 0 ? dataArray[index][15] : K.Map.noDataMessage
                
                publicData.append(
                    PublicData(infoType: .park,
                               name: name,
                               category: category,
                               address: address,
                               lat: latitude,
                               lon: longitude,
                               infra: infra,
                               organization: organization,
                               telephoneNumber: telephoneNumber)
                )
            }
        }
        
    }
    
    //MARK: - 산책로 데이터 로드
    
    private func loadStrollWayData() {
        
    }
    
    
    //MARK: - 지역명소 데이터 로드

    private func loadTourSpotData() {
        
    }
    
    
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

