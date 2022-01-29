//
//  NSImage+Extension.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/29.
//

import Foundation
import AppKit

extension NSImage {
    static func withOptionalURL(url: URL?) -> NSImage {
        var image = NSImage()
        if let url = url {
            image = NSImage(contentsOf: url) ?? NSImage()
        }
        return image
    }
}
