//
//  GoogleFontInteractorTests.swift
//  PicFontTests
//
//  Created by 賴柏宏 on 2022/9/26.
//

import XCTest
@testable import PicFont

final class GoogleFontInteractorTests: XCTestCase {
    class MockBLoC: BLoC<GoogleFontBLoC.Event, GoogleFontBLoC.State> {
        var didCall: ((GoogleFontBLoC.Event) -> Void)?
        init(didCall: ((GoogleFontBLoC.Event) -> Void)? = nil) {
            self.didCall = didCall
            super.init(state: .none)
        }
        
        override func add(event: GoogleFontBLoC.Event) {
            didCall?(event)
        }
    }
    
    class MockPresenter: GoogleFontPresentationLogic {
        var result: ((GoogleFontInteractor.State) -> Void)?
        init(result: ((GoogleFontInteractor.State) -> Void)? = nil) {
            self.result = result
        }
        
        func present(state: GoogleFontInteractor.State) {
            result?(state)
        }
    }
    
    func test_active_font() {
        let interactor = GoogleFontInteractor(bloc: MockBLoC())
        
        let exp = expectation(description: #function)
        let presenter = MockPresenter(result: {
            XCTAssertTrue($0 == .active("font"))
            exp.fulfill()
        })
        interactor.presenter = presenter
        interactor.active(fontName: "font")
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_font() {
        let exp = expectation(description: #function)
        let bloc = MockBLoC(didCall: {
            XCTAssertEqual($0, .loadFonts)
            exp.fulfill()
        })
        let interactor = GoogleFontInteractor(bloc: bloc)
        
        interactor.loadFonts()
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_download_font() {
        let exp = expectation(description: #function)
        let bloc = MockBLoC(didCall: {
            XCTAssertEqual($0, .downloadFile(PicFontTests.mockDomainModel()))
            exp.fulfill()
        })
        let interactor = GoogleFontInteractor(bloc: bloc)
        
        let domain = PicFontTests.mockDomainModel()
        domain.downloaded = false
        interactor.tap(at: domain)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_downloaded_font() {
        let interactor = GoogleFontInteractor(bloc: MockBLoC())
        
        let exp = expectation(description: #function)
        let presenter = MockPresenter(result: {
            XCTAssertTrue($0 == .downloadedFonts(PicFontTests.mockDomainModel()))
            exp.fulfill()
        })
        interactor.presenter = presenter
        let model = PicFontTests.mockDomainModel()
        model.downloaded = true
        interactor.tap(at: model)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_update_state() {
        let exp = expectation(description: #function)
        let bloc = MockBLoC()
        let interactor = GoogleFontInteractor(bloc: bloc)
        let presenter = MockPresenter(result: {
            XCTAssertTrue($0 == .downloadingFonts(PicFontTests.mockDomainModel()))
            exp.fulfill()
        })
        interactor.presenter = presenter
        
        bloc.state = .downloadingFonts(PicFontTests.mockDomainModel())
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_state_map() {
        let model = PicFontTests.mockDomainModel()
        XCTAssertEqual(GoogleFontInteractor.State(state: .downloadingFonts(model)), .downloadingFonts(model))
        XCTAssertEqual(
            GoogleFontInteractor.State(state: .downloadError(model, NSError(domain: "", code: 123))),
            .downloadError(model, NSError(domain: "", code: 123))
        )
        XCTAssertEqual(GoogleFontInteractor.State(state: .downloadedFiles(model)), .downloadedFonts(model))
        XCTAssertEqual(
            GoogleFontInteractor.State(state: .loadedFonts(PicFontTests.mockGoogleFontModel())),
            .loadedFonts(PicFontTests.mockGoogleFontModel())
        )
        XCTAssertEqual(GoogleFontInteractor.State(state: .loadingFonts), .loadingFonts)
        XCTAssertEqual(
            GoogleFontInteractor.State(state: .error(NSError(domain: "", code: 123))),
            .loadingError(NSError(domain: "", code: 123))
        )
        XCTAssertEqual(GoogleFontInteractor.State(state: .none), nil)
    }
}
