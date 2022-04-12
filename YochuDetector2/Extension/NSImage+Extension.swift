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
    
    var cgImage: CGImage? {
            guard let imageData = self.tiffRepresentation else { return nil }
            guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
            return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
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
    
    func crop(to rect: CGRect) -> NSImage {
        guard let cgImage = self.cgImage,
              let croppedCgImage = cgImage.cropping(to: rect) else { fatalError() }
        return NSImage(cgImage: croppedCgImage, size: rect.size)
    }
}
