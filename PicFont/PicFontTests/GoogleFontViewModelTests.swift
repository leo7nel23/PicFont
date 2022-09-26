//
//  GoogleFontViewModelTests.swift
//  PicFontTests
//
//  Created by 賴柏宏 on 2022/9/26.
//

import XCTest
@testable import PicFont
import Session
import Utility

final class GoogleFontViewModelTests: XCTestCase {
    func test_load_font_list() {
        let vm = GoogleFontViewModel()
        vm.present(state: .loadingFonts)
        
        XCTAssertTrue(vm.isLoading)
        XCTAssertNil(vm.loadingError)
    }
    
    func test_load_font_fail() {
        let vm = GoogleFontViewModel()
        vm.present(state: .loadingError(NSError(domain: "", code: 123)))
        
        XCTAssertFalse(vm.isLoading)
        XCTAssertNotNil(vm.loadingError)
    }
    
    func test_load_font_Complete() {
        let vm = GoogleFontViewModel()
        vm.present(
            state: .loadedFonts(
                GoogleFontModel(items: [
                    GoogleFontModel.FontModel(family: "family", variants: ["1"], files: ["1": "https://"])
                ])
            )
        )
        
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.loadingError)
        XCTAssertEqual(vm.contentViewModel.count, 1)
    }
    
    func test_download_font() {
        let vm = GoogleFontViewModel()
        let domainModel = PicFontTests.mockDomainModel()
        vm.present(state: .downloadingFonts(domainModel))
        XCTAssertTrue(domainModel.isLoading)
        XCTAssertNil(domainModel.error)
    }
    
    func test_download_font_fail() {
        let vm = GoogleFontViewModel()
        let domainModel = PicFontTests.mockDomainModel()
        vm.present(state: .downloadError(domainModel, NSError(domain: "123", code: 123)))
        XCTAssertFalse(domainModel.isLoading)
        XCTAssertNotNil(domainModel.error)
    }
    
    func test_download_font_complete() {
        class MockFileStorage: FileStorageProtocol {
            func save(data: Data, fileName: String) throws {}
            func containt(fileName: String) -> Bool { return true }
            func path(for fileName: String) -> URL { URL(string: "https://")! }
        }
        
        let vm = GoogleFontViewModel()
        let domainModel = PicFontTests.mockDomainModel(storage: MockFileStorage())
        vm.present(state: .downloadedFonts(domainModel))
        XCTAssertFalse(domainModel.isLoading)
        XCTAssertNil(domainModel.error)
        XCTAssertTrue(domainModel.downloaded)
        XCTAssertEqual(domainModel.supportTypes, ["regular"])
        XCTAssertEqual(vm.supportedTypes.first, ".AppleSystemUIFont")
    }
    
    func test_active_font_nil() {
        let vm = GoogleFontViewModel()
        vm.present(state: .active(nil))
        
        XCTAssertEqual(vm.currentFont.pointSize, 24)
        XCTAssertEqual(vm.currentFont.familyName, ".AppleSystemUIFont")
    }
    
    func test_active_font() {
        let vm = GoogleFontViewModel()
        vm.present(state: .active("Helvetica Neue"))
        
        XCTAssertEqual(vm.currentFont.pointSize, 24)
        XCTAssertEqual(vm.currentFont.familyName, "Helvetica Neue")
    }
    
    func test_active_font_not_exist() {
        let vm = GoogleFontViewModel()
        vm.present(state: .active("Helvetica NeuAe"))
        
        XCTAssertEqual(vm.currentFont.pointSize, 24)
        XCTAssertEqual(vm.currentFont.familyName, ".AppleSystemUIFont")
    }
}
