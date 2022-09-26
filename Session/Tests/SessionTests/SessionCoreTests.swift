//
//  SessionCoreTests.swift
//
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation
import XCTest
import Combine
@testable import Session
import TestHelper

struct MockParameter: SessionParameterProtocol {
    typealias Response = MockResponseModel
    
    var path: String
    var timeout: TimeInterval
    var httpMethod: HTTPMethod
    var anyAdapters: [RequestAdapter]
    
    init(path: String = "PATH",
         timeout: TimeInterval = 20,
         httpMethod: HTTPMethod = .post,
         anyAdapters: [RequestAdapter] = []
    ) {
        self.path = path
        self.timeout = timeout
        self.httpMethod = httpMethod
        self.anyAdapters = anyAdapters
    }
    
    static func response(with title: String = "title") -> String {
        return "{\"title\":\"\(title)\"}"
    }
    
    struct MockResponseModel: Decodable {
        var title: String
    }
}

class SessionCoreTests: XCTestCase {
    
    func test_Session_Complete() async throws {
        // give
        let parameter = MockParameter()
        let title = "Mock"
        
        MockAPI(
            parameter: parameter,
            data: MockParameter.response(with: title)
        ).register()
        
        // when
        let model = try await Session
            .shared
            .request(parameter)
            .asyncSinked()
        
        // then
        XCTAssertEqual(model?.title, title)
    }
    
    func test_Session_BadServer() async throws {
        // give
        let parameter = MockParameter()
        let title = "Mock"
        
        MockAPI(
            parameter: parameter,
            data: MockParameter.response(with: title),
            statusCode: 100
        ).register()
        
        do {
            // when
            _ = try await Session
                .shared
                .request(parameter)
                .asyncSinked()
        } catch {
            // then
            XCTAssertEqual(error as? SesssionError, SesssionError.responseError(.badServerResponse(100)))
        }
    }
    
    func test_Session_EmptyPath() async throws {
        let parameter = MockParameter(path: "")
        
        do {
            // when
            _ = try await Session
                .shared
                .request(parameter)
                .asyncSinked()
        } catch {
            // then
            XCTAssertEqual(error as? SesssionError, SesssionError.requestError(.invalidURL("")))
        }
    }
    
    func test_Session_AnyAdapter() throws {
        let parameter = MockParameter(anyAdapters: [
            AnyRequestAdapter({
                $0.timeoutInterval = 100
            })
        ])
        
        let request = try parameter.asURLRequest()
        
        XCTAssertEqual(request.timeoutInterval, 100)
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_Session_ParameterExtension() {
        struct Parameter: SessionParameterProtocol {
            typealias Response = MockParameter.MockResponseModel
            var path: String = ""
        }
        
        let parameter = Parameter()
        
        XCTAssertEqual(parameter.httpMethod, .get)
        XCTAssertEqual(parameter.timeout, 10)
        XCTAssertEqual(parameter.anyAdapters.count, 0)
        XCTAssertNil(parameter.requestModel)
    }
    
    func test_MockAPI_Dictionary() throws {
        // give
        let title = "Mock"
        let dict = ["title": title]
        
        // when
        let model = try JSONDecoder().decode(MockParameter.MockResponseModel.self, from: dict.asData())
        
        // then
        XCTAssertEqual(model.title, title)
    }
    
    func test_MockAPI_Data() throws {
        // give
        let title = "Mock"
        let data = try XCTUnwrap(MockParameter.response(with: title).data(using: .utf8))
        
        // when
        let model = try JSONDecoder().decode(MockParameter.MockResponseModel.self, from: data)
        
        // then
        XCTAssertEqual(model.title, title)
    }
}
