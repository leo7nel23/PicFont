//
//  RequestAdapter.swift
//
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation

public protocol RequestAdapter {
    func adapted(request: inout URLRequest) throws
}

public struct AnyRequestAdapter: RequestAdapter {
    var block: (inout URLRequest) -> Void
    
    public init(_ block: @escaping ((inout URLRequest) -> Void)) {
        self.block = block
    }
    
    public func adapted(request: inout URLRequest) throws {
        block(&request)
    }
}

public struct TimeoutAdapter: RequestAdapter {
    let timeout: TimeInterval
    
    public func adapted(request: inout URLRequest) throws {
        request.timeoutInterval = timeout
    }
}

public struct HttpMethodAdapter: RequestAdapter {
    let httpMethod: HTTPMethod
    
    public func adapted(request: inout URLRequest) throws {
        request.httpMethod = httpMethod.rawValue
    }
}
