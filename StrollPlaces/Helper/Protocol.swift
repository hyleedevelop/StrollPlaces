//
//  Protocol.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/05.
//

import Foundation

protocol ViewModel {

    associatedtype Action
    associatedtype State

    var action: Action { get }
    var state: State { get }
}
