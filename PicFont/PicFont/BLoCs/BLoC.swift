//
//  BLoC.swift
//  PicFont
//
//  Created by 賴柏宏 on 2022/9/24.
//

import Foundation
import Combine

open class BLoC<Event: Equatable, State: Equatable> {
    @Published var state: State
    @Published var event: Event?
    
    var cancellables = Set<AnyCancellable>()
    
    init(state: State) {
        self.state = state
    }
    
    func mapEventToState(event: Event) {
        preconditionFailure("This method must be overridden")
    }
    
    func add(event: Event) {
        preconditionFailure("This method must be overridden")
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
