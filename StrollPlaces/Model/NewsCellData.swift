//
//  NewsCellData.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/24.
//

import Foundation

// MARK: - News

struct NewsResponse: Decodable {
    
    let lastBuildDate: String
    let total, start, display: Int
    let items: [News]
    
}

// MARK: - Item

struct News: Decodable {
    
    let title: String
    let originalLink: String
    let link: String
    let description, pubDate: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case originalLink = "originallink"
        case link
        case description
        case pubDate
    }
    
}
