//
//  GoogleFontViewModel.swift
//  PicFont
//
//  Created by 賴柏宏 on 2022/9/24.
//

import Foundation
import Session
import Combine
import UIKit

final class GoogleFontViewModel {
    weak var viewController: GoogleFontViewController? {
        didSet {
            viewController?.title = title
        }
    }
    var title: String = "Google Font"
    
    @Published var contentViewModel: [GoogleFontTableViewCellViewModel] = []
    @Published var isLoading: Bool = false
    @Published var loadingError: Error?
    
    @Published var supportedTypes: [String] = []
    @Published var currentFont: UIFont = UIFont.systemFont(ofSize: 20)
}

extension GoogleFontViewModel: GoogleFontPresentationLogic {
    func present(state: GoogleFontInteractor.State) {
        if case let .loadingError(error) = state {
            loadingError = error
        } else {
            loadingError = nil
        }
        
        isLoading = (state == .loadingFonts)
        if case let .loadedFonts(model) = state {
            contentViewModel = model.items.lazy.map({
                let domainModel = GoogleFontDomainModel(model: $0)
                return GoogleFontTableViewCellViewModel(model: domainModel)
            })
        }
        
        switch state {
        case .downloadingFonts(let googleFontDomainModel):
            googleFontDomainModel.isLoading = true
        case .downloadError(let googleFontDomainModel, let error):
            googleFontDomainModel.error = error
        case .downloadedFonts(let googleFontDomainModel):
            googleFontDomainModel.isLoading = false
            googleFontDomainModel.checkDownloadResult()
            if googleFontDomainModel.downloaded {
                supportedTypes = UIFont.fontNames(forFamilyName: googleFontDomainModel.family)
            }
        case .active(let fontName):
            if let fontName = fontName {
                currentFont = UIFont(name: fontName, size: 24) ?? .systemFont(ofSize: 24)
                contentViewModel
                    .first(where: { $0.fontModel.family == currentFont.familyName })?
                    .fontModel
                    .usedFont = fontName
            } else {
                currentFont = UIFont.systemFont(ofSize: 24)
            }
        default:
            break
        }
    }
}
