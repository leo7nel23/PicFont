//
//  FileManager+Ext.swift
//  
//
//  Created by 賴柏宏 on 2022/9/24.
//

import Foundation

public protocol FileStorageProtocol {
    func save(data: Data, fileName: String) throws
    func containt(fileName: String) -> Bool
    func path(for fileName: String) -> URL
}

extension FileManager: FileStorageProtocol {
    public func path(for fileName: String) -> URL {
        guard let path = urls(for: .documentDirectory, in: .userDomainMask).first else {
            return URL(string: "")!
        }
        return path.appendingPathComponent(fileName)
    }
    public func containt(fileName: String) -> Bool {
        guard let path = urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        let url = path.appendingPathComponent(fileName)
        
        do {
            return try url.checkResourceIsReachable()
        } catch {
            return false
        }
    }
    
    public func save(data: Data, fileName: String) throws {
        guard let path = urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let url = path.appendingPathComponent(fileName)
        try data.write(to: url)
    }
}
