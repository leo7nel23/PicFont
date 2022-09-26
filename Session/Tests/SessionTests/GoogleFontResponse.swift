//
//  File.swift
//  
//
//  Created by 賴柏宏 on 2022/9/24.
//

import Foundation

struct GoogleFontResponse {
    static let defaultFont: [String: Any] =
    [
        "kind": "webfonts#webfontList",
        "items": [
            [
                "family": "ABeeZee",
                "variants": [
                    "regular",
                    "italic"
                ],
                "files": [
                    "regular": "http://fonts.gstatic.com/s/abeezee/v22/esDR31xSG-6AGleN6tKukbcHCpE.ttf",
                    "italic": "http://fonts.gstatic.com/s/abeezee/v22/esDT31xSG-6AGleN2tCklZUCGpG-GQ.ttf"
                ],
            ],
            [
                "family": "Abel",
                "variants": [
                    "regular"
                ],
                "files": [
                    "regular": "http://fonts.gstatic.com/s/abel/v18/MwQ5bhbm2POE6VhLPJp6qGI.ttf"
                ]
            ]
        ]
    ]
}
