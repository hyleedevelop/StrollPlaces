//
//  URLRequest.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/24.
//

import Foundation
import RxSwift
import RxCocoa

struct Resource<T: Decodable> {
    let urlRequest: URLRequest
}

extension URLRequest {
    
    static func load<T>(resource: Resource<T>) -> Observable<T> {
        return Observable.just(resource.urlRequest)
            .flatMap { urlRequest -> Observable<Data> in
                return URLSession.shared.rx.data(request: urlRequest)
            }
            .map { data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            }
            .asObservable()
    }
    
}
