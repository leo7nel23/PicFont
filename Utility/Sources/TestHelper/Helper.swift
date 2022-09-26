//
//  Helper.swift
//  
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation
import Combine

public extension Publisher {
    @discardableResult
    func asyncSinked() async throws -> Output? {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var output: Output?
            
            // 使用 last 確保 app 內的行為都跑完了，才啟動 Unit Test
            cancellable = last()
                .sink { result in
                    switch result {
                    case .finished:
                        continuation.resume(returning: output)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    output = value
                }
        }
    }
}
