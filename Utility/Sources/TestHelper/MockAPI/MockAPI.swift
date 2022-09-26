//
//  MockAPI.swift
//
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation

public protocol DataConvertible {
    func asData() -> Data
}

extension Data: DataConvertible {
    public func asData() -> Data { self }
}

extension String: DataConvertible {
    public func asData() -> Data { data(using: .utf8) ?? Data() }
}

extension Dictionary: DataConvertible where Key == String, Value: Any {
    public func asData() -> Data { try! JSONSerialization.data(withJSONObject: self, options: []) }
}

public struct MockResponseData {
    let data: DataConvertible
    let statusCode: Int
    
    public init(data: DataConvertible, statusCode: Int = 200) {
        self.data = data
        self.statusCode = statusCode
    }
}

public class MockAPI: Equatable {
    public static func == (lhs: MockAPI, rhs: MockAPI) -> Bool { lhs.urlRequest == rhs.urlRequest }
    public var unregisterAfterCompletion: Bool
    let urlRequest: URLRequest
    let response: MockResponseData
    
    public var didComplete: (() -> Void)?
    
    public init(
        urlRequest: URLRequest,
        response: MockResponseData,
        unregisterAfterCompletion: Bool = true
    ) {
        self.urlRequest = urlRequest
        self.response = response
        self.unregisterAfterCompletion = unregisterAfterCompletion
    }
    
    public func register() {
        Mocker.shared.register(self)
    }
    
    func unregisterIfNeed() {
        guard unregisterAfterCompletion else { return }
        unregister()
    }
    
    public func unregister() {
        Mocker.shared.unregister(self)
    }
}
