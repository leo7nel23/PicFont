//
//  GoogleFontCoordinator.swift
//  PicFont
//
//  Created by 賴柏宏 on 2022/9/24.
//

import Foundation
import UIKit

struct GoogleFontCoordinator {
    private let presenter: UINavigationController
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let viewController = GoogleFontViewController()
        presenter.pushViewController(viewController, animated: true)
    }
}
