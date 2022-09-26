//
//  GoogleFontModel.swift
//  
//
//  Created by 賴柏宏 on 2022/9/24.
//

import Foundation

public struct GoogleFontModel: Codable {
    public struct FontModel: Codable {
        public var family: String
        public var variants: [String]
        public var files: [String: String]
        
        public init(family: String, variants: [String], files: [String : String]) {
            self.family = family
            self.variants = variants
            self.files = files
        }
    }
    public var items: [FontModel]
    
    public init(items: [FontModel]) {
        self.items = items
    }
}
