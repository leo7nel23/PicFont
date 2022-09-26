//
//  UIImageView+Ext.swift
//
//
//  Created by 賴柏宏 on 2022/7/18.
//

import Foundation
import UIKit
import CommonCrypto

public protocol ImageHandlerProtocol {
    func save(image: UIImage, key: String)
    func load(key: String) -> UIImage?
}

public final class ImageCacheHandler {
    public static let shared: ImageCacheHandler = ImageCacheHandler(handler: FileManager.default)
    
    let operation: OperationQueue = {
        let op = OperationQueue()
        op.maxConcurrentOperationCount = 10
        return op
    }()
    
    let imageHandler: ImageHandlerProtocol
    
    init(handler: ImageHandlerProtocol) {
        self.imageHandler = handler
    }
    
    func loadImage(url: URL) async throws -> UIImage {
        if let image = imageHandler.load(key: url.absoluteString) {
            return image
        }
        
        return try await withCheckedThrowingContinuation({ continuation in
            operation.addOperation { [weak self] in
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    
                    self?.imageHandler.save(image: image, key: url.absoluteString)
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(returning: UIImage())
                }
            }
        })
    }
}

public extension UIImageView {
    func setImage(
        _ path: String,
        handler: ImageCacheHandler = ImageCacheHandler.shared
    ) {
        guard let url = URL(string: path) else { return }
        image = nil
        Task {
            image = try? await handler.loadImage(url: url)
        }
    }
}

extension FileManager: ImageHandlerProtocol {
    public func save(image: UIImage, key: String) {
        do {
            let cacheDirectory = try url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor:nil,
                create:false
            )
            let fileURL = cacheDirectory.appendingPathComponent(key.imageFileName)
            if let imageData = image.jpegData(compressionQuality: 1) {
                try imageData.write(to: fileURL)
            }
        } catch {
            print(error)
        }
    }
    
    public func load(key: String) -> UIImage? {
        do {
            let cacheDirectory = try url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor:nil,
                create:false
            )
            let fileURL = cacheDirectory.appendingPathComponent(key.imageFileName)
            if fileExists(atPath: fileURL.path) {
                return UIImage(contentsOfFile: fileURL.path)
            }
        } catch {
            print(error)
        }
        return nil
    }
}

extension String {
    internal var imageFileName: String { sha256 + ".jpg" }
    
    private var sha256: String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
}
