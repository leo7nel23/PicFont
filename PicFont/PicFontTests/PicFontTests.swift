//
//  PicFontTests.swift
//  PicFontTests
//
//  Created by 賴柏宏 on 2022/9/24.
//

import XCTest
@testable import PicFont
import Session
import Utility

struct PicFontTests {
    static func mockFontModel(
        family: String = ".AppleSystemUIFont",
        variants: [String] = ["regular"],
        files: [String: String] = ["regular": "https://google.com"]
    ) -> GoogleFontModel.FontModel {
        return GoogleFontModel.FontModel(family: family, variants: variants, files: files)
    }
    
    static func mockGoogleFontModel(
        items: [GoogleFontModel.FontModel]? = nil
    ) -> GoogleFontModel {
        return GoogleFontModel(items: items ?? [mockFontModel()])
    }
    
    static func mockDomainModel(
        model: GoogleFontModel.FontModel? = nil,
        storage: FileStorageProtocol = FileManager.default
    ) -> GoogleFontDomainModel {
        return GoogleFontDomainModel(
            model: model ?? mockFontModel(),
            storage: storage
        )
    }
}
