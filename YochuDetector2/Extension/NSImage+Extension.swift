//
//  NSImage+Extension.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/29.
//

import Foundation
import AppKit

extension NSImage {
    var ciImage: CIImage? {
        guard let imageData = self.tiffRepresentation else { return nil }
        return CIImage(data: imageData)
    }
    
    static func withOptionalURL(url: URL?) -> NSImage {
        var image = NSImage()
        if let url = url {
            image = NSImage(contentsOf: url) ?? NSImage()
        }
        return image
    }
    
    func addBoundingRectangle(with rect: CGRect) {
        guard let rectangleNsImage = NSImage(named: "box") else { return }
        
        self.lockFocus()
        rectangleNsImage.draw(in: rect)
        self.unlockFocus()
    }
}
