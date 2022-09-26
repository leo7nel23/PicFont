//
//  Session.swift
//
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation
import Combine
import TestHelper

public let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}()

public class Session {
    public static let shared: Session = Session()
    private init() {}
    
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        #if DEBUG_MODE
        config.protocolClasses = [MockURLProtocol.self]
        #endif
        return URLSession(configuration: config)
    }()
    
    public func request<T>(
        _ parameter: T,
        decoder: JSONDecoder = decoder
    ) -> AnyPublisher<T.Response, Error> where T: SessionParameterProtocol {
        do {
            return session
                .dataTaskPublisher(for: try parameter.asURLRequest())
                .tryMap({ element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        let code = (element.response as? HTTPURLResponse)?.statusCode
                        throw SesssionError.responseError(.badServerResponse(code))
                    }
                    return element.data
                })
                .decode(type: T.Response.self, decoder: decoder)
                .eraseToAnyPublisher()
        } catch {
            return Fail(outputType: T.Response.self, failure: error)
                .eraseToAnyPublisher()
        }
    }
    
    public func download(
        fileURL: URL
    ) -> AnyPublisher<Data, Error> {
        session
            .dataTaskPublisher(for: fileURL)
            .map { $0.data }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

extension SessionParameterProtocol {
    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: path) else {
            throw SesssionError.requestError(.invalidURL(path))
        }
        
        var request = URLRequest(url: url)
        try request.adapted(with: self)
        return request
    }
}
