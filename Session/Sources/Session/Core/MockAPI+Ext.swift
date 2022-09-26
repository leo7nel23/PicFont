//
//  MockAPI+Ext.swift
//
//
//  Created by 賴柏宏 on 2022/7/17.
//

import Foundation
import TestHelper

extension MockAPI {
    public convenience init<T: SessionParameterProtocol>(
        parameter: T,
        response: MockResponseData,
        unregisterAfterCompletion: Bool = true
    ) {
        let path = parameter.path.count > 0 ? parameter.path : "PATH"
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = parameter.httpMethod.rawValue
        request.timeoutInterval = parameter.timeout
        
        self.init(
            urlRequest: request,
            response: response,
            unregisterAfterCompletion: unregisterAfterCompletion
        )
    }
    
    public convenience init<T: SessionParameterProtocol>(
        parameter: T,
        data: DataConvertible,
        statusCode: Int = 200
    ) {
        self.init(
            parameter: parameter,
            response: MockResponseData(
                data: data,
                statusCode: statusCode
            )
        )
    }
}
