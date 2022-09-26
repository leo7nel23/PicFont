//
//  URLRequest+Ext.swift
//
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation

extension URLRequest {
    mutating func adapted<T>(with parameter: T) throws where T: SessionParameterProtocol {
        var adapters: [RequestAdapter] = [
            HttpMethodAdapter(httpMethod: parameter.httpMethod),
            TimeoutAdapter(timeout: parameter.timeout)
        ]
        adapters.append(contentsOf: parameter.anyAdapters)
        
        try adapters.forEach { try $0.adapted(request: &self) }
    }
}
