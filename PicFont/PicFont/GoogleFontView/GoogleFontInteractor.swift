//
//  GoogleFontInteractor.swift
//  PicFont
//
//  Created by 賴柏宏 on 2022/9/24.
//

import Foundation
import Session
import Combine
import UIKit

protocol GoogleFontPresentationLogic: AnyObject {
    func present(state: GoogleFontInteractor.State)
}

class GoogleFontInteractor {
    enum State: Equatable {
        static func == (lhs: GoogleFontInteractor.State, rhs: GoogleFontInteractor.State) -> Bool {
            switch (lhs, rhs) {
            case (.loadingFonts, .loadingFonts):
                return true
            case (.downloadingFonts(_), .downloadingFonts(_)):
                return true
            case (.loadingError(_), .loadingError(_)):
                return true
            case (.downloadError(_, _), .downloadError(_, _)):
                return true
            case (.loadedFonts(_), .loadedFonts(_)):
                return true
            case (.downloadedFonts(_), .downloadedFonts(_)):
                return true
            case (.active(let lFont), .active(let rFont)):
                return lFont == rFont
            default:
                return false
            }
        }
        case loadingFonts
        case downloadingFonts(GoogleFontDomainModel)
        
        case loadingError(Error)
        case downloadError(GoogleFontDomainModel, Error)
        
        case loadedFonts(GoogleFontModel)
        case downloadedFonts(GoogleFontDomainModel)
        
        case active(String?)
        
        init?(state: GoogleFontBLoC.State) {
            switch state {
            case .none:
                return nil
            case .loadingFonts:
                self = .loadingFonts
            case .loadedFonts(let googleFontModel):
                self = .loadedFonts(googleFontModel)
            case .error(let error):
                self = .loadingError(error)
            case .downloadingFonts(let googleFontDomainModel):
                self = .downloadingFonts(googleFontDomainModel)
            case .downloadedFiles(let googleFontDomainModel):
                self = .downloadedFonts(googleFontDomainModel)
            case .downloadError(let googleFontDomainModel, let error):
                self = .downloadError(googleFontDomainModel, error)
            }
        }
    }
    
    
    private let bloc: BLoC<GoogleFontBLoC.Event, GoogleFontBLoC.State>
    weak var presenter: GoogleFontPresentationLogic?
    var cancellables: Set<AnyCancellable> = []
    
    init(bloc: BLoC<GoogleFontBLoC.Event, GoogleFontBLoC.State> = GoogleFontBLoC()) {
        self.bloc = bloc
        bindData()
    }
    
    func tap(at model: GoogleFontDomainModel) {
        if model.downloaded {
            presenter?.present(state: .downloadedFonts(model))
        } else {
            bloc.add(event: .downloadFile(model))
        }
    }
    
    func loadFonts() {
        bloc.add(event: .loadFonts)
    }
    
    func active(fontName: String?) {
        presenter?.present(state: .active(fontName))
    }
    
    private func bindData() {
        bloc
            .$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if let state = State(state: $0) {
                    self?.presenter?.present(state: state)
                }
            }
            .store(in: &cancellables)
    }
}
