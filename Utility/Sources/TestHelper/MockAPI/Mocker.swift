//
//  Mocker.swift
//
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation

class Mocker {
    static let shared: Mocker = Mocker()
    
    var mocks: [MockAPI] = []
    func register(_ api: MockAPI) {
        mocks.removeAll { $0 == api }
        mocks.append(api)
    }
    
    func unregister(_ api: MockAPI) {
        mocks.removeAll { $0 == api }
    }
    
    func mockAPI(for request: URLRequest) -> MockAPI? {
        mocks.first {
            $0.urlRequest.url?.absoluteString == request.url?.absoluteString
            && $0.urlRequest.httpMethod == request.httpMethod
        }
    }
    
    func shouldHandle(for request: URLRequest) -> Bool {
        return mockAPI(for: request) != nil
    }
}
