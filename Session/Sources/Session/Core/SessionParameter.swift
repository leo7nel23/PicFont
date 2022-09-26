//
//  SessionParameter.swift
//
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public protocol SessionParameterProtocol {
    associatedtype Response: Decodable
    
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var requestModel: Encodable? { get }
    var timeout: TimeInterval { get }
    var anyAdapters: [RequestAdapter] { get }
}

public extension SessionParameterProtocol {
    var requestModel: Encodable? { nil }
    var timeout: TimeInterval { 10 }
    var httpMethod: HTTPMethod { .get }
    var anyAdapters: [RequestAdapter] { [] }
}
