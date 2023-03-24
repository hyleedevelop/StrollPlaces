//
//  NewsCellData.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/24.
//

import Foundation

struct NewsResponse: Decodable {
    let newsList: [News]
}

struct News: Decodable {
    let title: String
    let description: String?
}
