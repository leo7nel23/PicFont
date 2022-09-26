//
//  APIClient.swift
//  PicFont
//
//  Created by 賴柏宏 on 2022/9/26.
//

import Foundation
import Combine
import Session

final class APIClient {
    static let shared: APIClient = APIClient()
    
    let session = Session.shared
    private init() {}
    
    func fetchGooglFonts() -> AnyPublisher<GoogleFontModel, Error> {
        let parameter = GoogleFontParameter()
        return session
            .request(parameter)
    }
    
    func download(fileURL: URL) -> AnyPublisher<Data, Error> {
        session.download(fileURL: fileURL)
    }
}
