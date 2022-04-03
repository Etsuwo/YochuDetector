//
//  CIImage+Extension.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/02/01.
//

import Foundation
import CoreImage
import AppKit

extension CIImage {
    
    var nsImage: NSImage {
        let rep = NSCIImageRep(ciImage: self)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
    
    func toCGImage(context: CIContext) -> CGImage {
        return context.createCGImage(self, from: self.extent)!
    }
    
    func toPixelBuffer(context: CIContext) -> CVPixelBuffer? {
        var maybePixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(nil, 640, 640, kCVPixelFormatType_32BGRA, nil, &maybePixelBuffer)
        guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else { return maybePixelBuffer }
        context.render(self, to: pixelBuffer)
        return pixelBuffer
    }
    
    func resizeWithWhiteBackground(context: CIContext, size: CGSize) -> CIImage {
        var resize = CGSize()
        var origin = CGPoint()
        if self.extent.size.height > self.extent.size.width {
            resize = CGSize(width: self.extent.size.width / self.extent.size.height * size.height, height: size.height)
            origin = CGPoint(x: 0, y: 0)
        } else {
            resize = CGSize(width: size.width, height: self.extent.size.height / self.extent.size.width * size.width)
            origin = CGPoint(x: 0, y: size.height - resize.height)
        }
        
        let cgImage = self.toCGImage(context: context)
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let cgContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { fatalError() }
        cgContext.setFillColor(CGColor.white)
        cgContext.fill(CGRect(origin: .zero, size: size))
        cgContext.draw(cgImage, in: CGRect(origin: origin, size: resize))
        
        guard let resizeImage = cgContext.makeImage() else { fatalError() }
        
        return CIImage(cgImage: resizeImage)
    }
}
