//
//  SessionAPITests.swift
//  
//
//  Created by 賴柏宏 on 2022/7/15.
//

import XCTest
import Foundation
@testable import Session
import TestHelper

class SessionAPITests: XCTestCase {
    func test_google_font_Complete() async throws {
        let parameter = GoogleFontParameter()
        
        MockAPI(
            parameter: parameter,
            data: GoogleFontResponse.defaultFont
        )
        .register()
        
        let result = try await Session
            .shared
            .request(parameter)
            .asyncSinked()
        
        let model = try XCTUnwrap(result)
        
        XCTAssertEqual(model.items.count, 2)
        
        let first = try XCTUnwrap(model.items.first)
        let last = try XCTUnwrap(model.items.last)
        
        XCTAssertEqual(first.family, "ABeeZee")
        XCTAssertEqual(first.variants.count, 2)
        XCTAssertEqual(first.variants.first, "regular")
        XCTAssertEqual(first.variants.last, "italic")
        XCTAssertEqual(
            first.files["regular"],
            "http://fonts.gstatic.com/s/abeezee/v22/esDR31xSG-6AGleN6tKukbcHCpE.ttf"
        )
        XCTAssertEqual(
            first.files["italic"],
            "http://fonts.gstatic.com/s/abeezee/v22/esDT31xSG-6AGleN2tCklZUCGpG-GQ.ttf"
        )
        
        XCTAssertEqual(last.family, "Abel")
        XCTAssertEqual(last.variants.count, 1)
        XCTAssertEqual(last.variants.first, "regular")
        XCTAssertEqual(
            last.files["regular"],
            "http://fonts.gstatic.com/s/abel/v18/MwQ5bhbm2POE6VhLPJp6qGI.ttf"
        )
    }
}
