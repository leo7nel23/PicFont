//
//  GoogleFontTableViewCellViewModel.swift
//  PicFont
//
//  Created by 賴柏宏 on 2022/9/24.
//

import Foundation
import UIKit
import Session
import Utility
import Combine

class GoogleFontTableViewCellViewModel {
    var title: String
    @Published var titleFont: UIFont
    var subTitle: String
    @Published var subTitleFont: UIFont
    @Published var showLoading: Bool = false
    @Published var icon: UIImage?
    
    var cancellables: Set<AnyCancellable> = []
    
    private(set) var fontModel: GoogleFontDomainModel
    
    init(model: GoogleFontDomainModel) {
        self.fontModel = model
        self.title = model.family
        self.subTitle = model.supportTypes.joined(separator: ", ")
        self.icon = model.downloaded ? nil : UIImage(systemName: "arrow.down")
        if let font = model.usedFont {
            self.titleFont = UIFont(name: font, size: 18) ?? .systemFont(ofSize: 18)
            self.subTitleFont = UIFont(name: font, size: 14) ?? .systemFont(ofSize: 14)
        } else {
            self.titleFont = .systemFont(ofSize: 18)
            self.subTitleFont = .italicSystemFont(ofSize: 14)
        }
        
        bindData()
    }
    
    private func bindData() {
        fontModel
            .$isLoading
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.showLoading = $0
                self?.icon = $0 ? nil : UIImage(systemName: "arrow.down")
            })
            .store(in: &cancellables)
        
        fontModel
            .$downloaded
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.icon = $0 ? nil : UIImage(systemName: "arrow.down")
            })
            .store(in: &cancellables)
        
        fontModel
            .$usedFont
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] font in
                guard let font = font else { return }
                self?.titleFont = UIFont(name: font, size: 18) ?? .systemFont(ofSize: 18)
                self?.subTitleFont = UIFont(name: font, size: 14) ?? .systemFont(ofSize: 14)
            })
            .store(in: &cancellables)
    }
}

class GoogleFontDomainModel {
    let model: GoogleFontModel.FontModel
    var family: String { model.family }
    @Published var usedFont: String?
    var supportTypes: [String]
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    @Published var downloaded: Bool = false
    let storage: FileStorageProtocol
    
    init(
        model: GoogleFontModel.FontModel,
        storage: FileStorageProtocol = FileManager.default
    ) {
        self.model = model
        self.storage = storage
        self.supportTypes = model.variants
        checkDownloadResult()
        self.usedFont = UIFont.fontNames(forFamilyName: family).first
    }
    
    func checkDownloadResult() {
        downloaded = {
            guard model.files.allSatisfy({
                self.storage.containt(fileName: model.fileName(for: $0.key))
            }) else {
                return false
            }
            
            model
                .files
                .forEach {
                    let path = self.storage.path(for: model.fileName(for: $0.key))
                    if let dataProvider = CGDataProvider(url: path as CFURL),
                       let font = CGFont(dataProvider) {
                        CTFontManagerRegisterGraphicsFont(font, nil)
                    }
                }
            
            return true
        }()
    }
}
