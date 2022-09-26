//
//  GoogleFontBLoCTests.swift
//  PicFontTests
//
//  Created by 賴柏宏 on 2022/9/26.
//

import XCTest
@testable import PicFont
import Session
import Combine
import Utility

final class GoogleFontBLoCTests: XCTestCase {
    class MockAPIClient: GoogleFontAPIProtocol {
        var error: Error?
        var fontModel: GoogleFontModel?
        var data: Data?
        
        init(error: Error? = nil, fontModel: GoogleFontModel? = nil, data: Data? = nil) {
            self.error = error
            self.fontModel = fontModel
            self.data = data
        }
        
        func fetchGooglFonts() -> AnyPublisher<GoogleFontModel, Error> {
            if let model = fontModel {
                return CurrentValueSubject<GoogleFontModel, Error>(model).eraseToAnyPublisher()
            } else {
                let error = error ?? NSError(domain: "", code: 123)
                return Fail(outputType: GoogleFontModel.self, failure: error)
                    .eraseToAnyPublisher()
            }
        }
        
        func download(fileURL: URL) -> AnyPublisher<Data, Error> {
            if let data = data {
                let subject = PassthroughSubject<Data, Error>()
                subject.send(data)
                subject.send(completion: .finished)
                return subject.eraseToAnyPublisher()
            } else {
                let error = error ?? NSError(domain: "123", code: 123)
                return Fail(outputType: Data.self, failure: error)
                    .eraseToAnyPublisher()
            }
        }
    }
    
    func test_bloc_loadFonts() {
        let mockAPI = MockAPIClient(fontModel: PicFontTests.mockGoogleFontModel())
        let bloc = GoogleFontBLoC(
            apiClient: mockAPI
        )
        
        let exp = expectation(description: #function)
        
        var results: [GoogleFontBLoC.State] = [
            .loadingFonts,
            .loadedFonts(PicFontTests.mockGoogleFontModel())
        ]
        
        let cancellable = bloc
            .$state
            .dropFirst()
            .sink(receiveValue: { state in
                XCTAssertTrue(state == results[0])
                results.removeFirst()
                
                if results.count == 0 {
                    exp.fulfill()
                }
            })
        
        bloc.add(event: .loadFonts)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_bloc_loadFonts_error() {
        let mockAPI = MockAPIClient(error: NSError(domain: "", code: 123))
        let bloc = GoogleFontBLoC(
            apiClient: mockAPI
        )
        
        let exp = expectation(description: #function)
        
        var results: [GoogleFontBLoC.State] = [
            .loadingFonts,
            .error(NSError(domain: "", code: 123))
        ]
        
        let cancellable = bloc
            .$state
            .dropFirst()
            .sink(receiveValue: { state in
                XCTAssertTrue(state == results[0])
                results.removeFirst()
                
                if results.count == 0 {
                    exp.fulfill()
                }
            })
        
        bloc.add(event: .loadFonts)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_bloc_download_files() {
        class MockFileStorage: FileStorageProtocol {
            func save(data: Data, fileName: String) throws {}
            func containt(fileName: String) -> Bool { return true }
            func path(for fileName: String) -> URL { URL(string: "https://")! }
        }
        
        let mockAPI = MockAPIClient(data: Data())
        let bloc = GoogleFontBLoC(
            apiClient: mockAPI,
            storage: MockFileStorage()
        )
        
        let domain = PicFontTests.mockDomainModel()
        let exp = expectation(description: #function)
        
        var results: [GoogleFontBLoC.State] = [
            .downloadingFonts(domain),
            .downloadedFiles(domain)
        ]
        
        let cancellable = bloc
            .$state
            .dropFirst()
            .sink(receiveValue: { state in
                XCTAssertTrue(state == results[0])
                results.removeFirst()
                
                if results.count == 0 {
                    exp.fulfill()
                }
            })
        
        bloc.add(event: .downloadFile(domain))
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_bloc_download_files_error() {
        class MockFileStorage: FileStorageProtocol {
            func save(data: Data, fileName: String) throws {}
            func containt(fileName: String) -> Bool { return true }
            func path(for fileName: String) -> URL { URL(string: "https://")! }
        }
        
        let mockAPI = MockAPIClient(error: NSError(domain: "", code: 123))
        let bloc = GoogleFontBLoC(
            apiClient: mockAPI,
            storage: MockFileStorage()
        )
        
        let domain = PicFontTests.mockDomainModel()
        let exp = expectation(description: #function)
        
        var results: [GoogleFontBLoC.State] = [
            .downloadingFonts(domain),
            .downloadError(domain, NSError(domain: "", code: 123))
        ]
        
        let cancellable = bloc
            .$state
            .dropFirst()
            .sink(receiveValue: { state in
                XCTAssertTrue(state == results[0])
                results.removeFirst()
                
                if results.count == 0 {
                    exp.fulfill()
                }
            })
        
        bloc.add(event: .downloadFile(domain))
        wait(for: [exp], timeout: 1000.0)
    }

    
}
