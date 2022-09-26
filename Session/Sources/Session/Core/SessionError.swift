//
//  SessionError.swift
//
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation

public enum SesssionError: Error {
    case requestError(RequestErrorReason)
    case responseError(ResponseErrorReason)
    
    public enum RequestErrorReason {
        case invalidURL(String)
    }
    
    public enum ResponseErrorReason {
        case badServerResponse(Int?)
        case parseJSONFail(String)
    }
}

extension SesssionError: Equatable {
    public static func == (lhs: SesssionError, rhs: SesssionError) -> Bool {
        switch (lhs, rhs) {
        case (.requestError(let rReason), .requestError(let lReason)):
            return rReason == lReason
            
        case (.responseError(let rReason), .responseError(let lReason)):
            return rReason == lReason
            
        default:
            return false
        }
    }
}

extension SesssionError.RequestErrorReason: Equatable {
    public static func == (lhs: SesssionError.RequestErrorReason, rhs: SesssionError.RequestErrorReason) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL(let rUrl), .invalidURL(let lUrl)):
            return rUrl == lUrl
        }
    }
}

extension SesssionError.ResponseErrorReason: Equatable {
    public static func == (lhs: SesssionError.ResponseErrorReason, rhs: SesssionError.ResponseErrorReason) -> Bool {
        switch (lhs, rhs) {
        case (.badServerResponse(let rCode), .badServerResponse(let lCode)):
            return rCode == lCode
            
        case (.parseJSONFail, .parseJSONFail):
            return true
            
        default:
            return false
        }
    }
}
