//
//  DirectoryHandler.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/05/30.
//

import Foundation

final class DirectoryHandler {
    func createDirectory(directoryName: String, to path: URL) -> URL {
        let directory = path.appendingPathComponent(directoryName)
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        return directory
    }
}
