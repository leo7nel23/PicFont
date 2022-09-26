//
//  GoogleFontParameter.swift
//  
//
//  Created by 賴柏宏 on 2022/9/24.
//

import Foundation

public struct GoogleFontParameter: SessionParameterProtocol {
    public typealias Response = GoogleFontModel
    
    public var path: String = "https://www.googleapis.com/webfonts/v1/webfonts?sort=popularity&key=AIzaSyAQSfTmr8Aq97Bxwc1gqm9fkzlE2wUW5u0"
    
    public init() { }
}
