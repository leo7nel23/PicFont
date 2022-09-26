//
//  AppCoordinator.swift
//  PicFont
//
//  Created by 賴柏宏 on 2022/9/24.
//

import Foundation
import UIKit

final class AppCoordinator {
    
    private var window: UIWindow
    private let rootViewController: UINavigationController
    private let fontCoordinator: GoogleFontCoordinator
    
    init(window: UIWindow) {
        self.window = window
        window.tintColor = .systemTeal
        window.backgroundColor = .systemBackground
        
        rootViewController = UINavigationController()
        
        fontCoordinator = GoogleFontCoordinator(presenter: rootViewController)
    }
    
    func start() {
        window.rootViewController = rootViewController
        fontCoordinator.start()
        window.makeKeyAndVisible()
    }
}
