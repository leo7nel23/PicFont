//
//  GoogleFontBLoC.swift
//  PicFont
//
//  Created by 賴柏宏 on 2022/9/24.
//

import Foundation
import Session
import Utility
import Combine

protocol GoogleFontAPIProtocol {
    func fetchGooglFonts() -> AnyPublisher<GoogleFontModel, Error>
    func download(fileURL: URL) -> AnyPublisher<Data, Error>
}

class GoogleFontBLoC: BLoC<GoogleFontBLoC.Event, GoogleFontBLoC.State> {
    enum Event: Equatable {
        static func == (lhs: GoogleFontBLoC.Event, rhs: GoogleFontBLoC.Event) -> Bool {
            switch (lhs, rhs) {
            case (.loadFonts, .loadFonts):
                return true
            case (.downloadFile(_), .downloadFile(_)):
                return true
            default:
                return false
            }
        }
        
        case loadFonts
        case downloadFile(GoogleFontDomainModel)
    }
    
    enum State: Equatable {
        static func == (lhs: GoogleFontBLoC.State, rhs: GoogleFontBLoC.State) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none):
                return true
            case (.loadingFonts, .loadingFonts):
                return true
            case (.loadedFonts, .loadedFonts):
                return true
            case (.error, .error):
                return true
            case (.downloadingFonts(_), .downloadingFonts(_)):
                return true
            case (.downloadedFiles(_), .downloadedFiles(_)):
                return true
            case (.downloadError(_, _), .downloadError(_, _)):
                return true
            default:
                return false
            }
        }
        
        case none
        case loadingFonts
        case loadedFonts(GoogleFontModel)
        case error(Error)
        
        case downloadingFonts(GoogleFontDomainModel)
        case downloadedFiles(GoogleFontDomainModel)
        case downloadError(GoogleFontDomainModel, Error)
    }
    
    let fontStorage: FileStorageProtocol
    let apiClient: GoogleFontAPIProtocol
    
    init(
        apiClient: GoogleFontAPIProtocol = APIClient.shared,
        storage: FileStorageProtocol = FileManager.default
    ) {
        self.apiClient = apiClient
        self.fontStorage = storage
        super.init(state: .none)
    }
    
    override func mapEventToState(event: Event) {
        switch event {
        case .loadFonts:
            guard state != .loadingFonts else { return }
            state = .loadingFonts
            loadFonts()
            
        case .downloadFile(let model):
            guard state != .downloadingFonts(model) else { return }
            state = .downloadingFonts(model)
            downloadFonts(in: model)
        }
    }
    
    override func add(event: Event) {
        mapEventToState(event: event)
    }
}

extension GoogleFontBLoC {
    fileprivate func loadFonts() {
        apiClient
            .fetchGooglFonts()
            .sink { [weak self] in
                switch $0 {
                case .failure(let error):
                    self?.state = .error(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] fontsModel in
                self?.state = .loadedFonts(fontsModel)
            }
            .store(in: &cancellables)
    }
    
    fileprivate func downloadFonts(in model: GoogleFontDomainModel) {
        let publishers: [AnyPublisher<(Data, String), Error>] = model
            .model
            .files
            .compactMap { dict in
                guard let url = URL(string: dict.value) else {
                    return nil
                }
                return apiClient
                    .download(fileURL: url)
                    .map { ($0, model.model.fileName(for: dict.key) )}
                    .eraseToAnyPublisher()
            }
        Publishers
            .MergeMany(publishers)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    self?.state = .downloadedFiles(model)
                case .failure(let error):
                    self?.state = .downloadError(model, error)
                }
            } receiveValue: { [weak self] result in
                try? self?.fontStorage.save(data: result.0, fileName: result.1)
            }
            .store(in: &cancellables)
    }
}

extension GoogleFontModel.FontModel {
    func fileName(for subset: String) -> String {
        "\(family)-\(subset).ttf"
    }
}

extension APIClient: GoogleFontAPIProtocol {}
