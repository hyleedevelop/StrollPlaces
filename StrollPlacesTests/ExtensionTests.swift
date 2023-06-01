//
//  StrollPlacesTests.swift
//  StrollPlacesTests
//
//  Created by Eric on 2023/03/13.
//

import XCTest
@testable import StrollPlaces

final class ExtensionTests: XCTestCase {
    
    //MARK: - 테스트 진행 전 기본값 설정
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    //MARK: - 테스트 진행
    
    // [Double] 단위 변환
    func test_doubleTypeUnitConversion() throws {
        let testSet: [(Double, Double)] = [
            (1.234.km, 1234),
            (1.234.m, 1.234),
            (60.minute, 1),
            (150.minute, 2.5)
        ]
        
        for i in 0..<testSet.count {
            XCTAssertEqual(
                testSet[i].0,
                testSet[i].1,
                #function + ": test no.\(i) failed!"
            )
        }
    }
    
    // [String] escaping String을 unescaping String으로 변환
    func test_makeUnescapingString() throws {
        let testSet: [(String, String)] = [
            ("&apos;string&apos;", "'string'"),
            ("A&amp;B", "A&B"),
            ("Hello<b>World</b>", "HelloWorld")
        ]
         
        for i in 0..<testSet.count {
            XCTAssertEqual(
                testSet[i].0.unescape(),
                testSet[i].1,
                #function + ": test no.\(i) failed!"
            )
        }
    }
    
    // [String] 날짜 String을 Date로 변환 (1)
    func test_StringToDateConversion1() throws {
        let testSet: [(String, String)] = [
            ("2023년 05월 07일 12시 35분 00초", "2023-05-07 03:35:00 +0000"),
            ("2022년 01월 18일 17시 01분 23초", "2022-01-18 08:01:23 +0000"),
        ]
        
        for i in 0..<testSet.count {
            XCTAssertEqual(
                testSet[i].0.toDate(mode: .myPlace)!.description,
                testSet[i].1,
                #function + ": test no.\(i) failed!"
            )
        }
    }
    
    // [String] 날짜 String을 Date로 변환 (2)
    func test_StringToDateConversion2() throws {
        let testSet: [(String, String)] = [
            ("Mon, 29 MAY 2023 15:00:00", "2023-05-29 06:00:00 +0000"),
            ("Thu, 02 DEC 2021 21:15:43", "2021-12-02 12:15:43 +0000"),
        ]
        
        for i in 0..<testSet.count {
            XCTAssertEqual(
                testSet[i].0.toDate(mode: .news)!.description,
                testSet[i].1,
                #function + ": test no.\(i) failed!"
            )
        }
    }
    
    //MARK: - 테스트 진행 후 초기 상태로 복원
    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

}
