//
//  Publisher+Ext.swift
//
//
//  Created by 賴柏宏 on 2022/7/17.
//

import Foundation
import Combine

public extension Publisher {
    func sink(
        receiveCompletion: (() -> Void)? = nil,
        receiveValue: @escaping ((Output) -> Void),
        receiveFailure: ((Error) -> Void)? = nil
    ) -> AnyCancellable {
        sink { completion in
            switch completion {
            case .finished:
                receiveCompletion?()
            case .failure(let error):
                receiveFailure?(error)
            }
        } receiveValue: { output in
            receiveValue(output)
        }

    }
}
