//
//  ObjectTests.swift
//  StrollPlacesTests
//
//  Created by Eric on 2023/06/01.
//

import XCTest
import RxSwift
@testable import StrollPlaces

final class MethodTests: XCTestCase {
    
    //MARK: - 테스트 진행 전 기본값 설정
    
    override func setUp() {
        super.setUp()
    }
    
    //MARK: - 테스트 진행
    
    // 뉴스 기사 네트워킹
    func test_FetchNewsUsingAPI() throws {
        let searchKeyword = "산책길"
        var resource: Resource<NewsResponse> {
            let urlString = "https://openapi.naver.com/v1/search/news.json?query=\(searchKeyword)&display=100&sort=date"
            return Resource<NewsResponse>(urlRequest: urlString.toURLRequest())
        }
        
        let promise = expectation(description: "Status code: 200")
        var statusCode: Int?
        var responseError: Error?

        let dataTask = URLSession.shared.dataTask(with: resource.urlRequest) { _, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        
        dataTask.resume()
        wait(for: [promise], timeout: 5)
        
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
        
        URLRequest.load(resource: resource)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { response in
                XCTAssertNil(response.items.first)
            })
            .disposed(by: rx.disposeBag)
    }
    
    // 텍스트 필드 입력값 검사
    func test_ValidateTextFieldInput() throws {
        
    }
   
    //MARK: - 테스트 진행 후 초기 상태로 복원
    
    override func tearDown() {
        super.tearDown()
    }

}
