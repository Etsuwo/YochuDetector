//
//  ImageSaver.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/02/27.
//

import Foundation
import AppKit

final class ImageSaver {
    func save(image: NSImage, fileName: String, to output: URL) {
        let url = output.appendingPathComponent(fileName)
        guard let cgImage = image.cgImage else { fatalError() }
        let rep = NSBitmapImageRep(cgImage: cgImage)
        let data = rep.representation(using: .jpeg, properties: [:])
        do {
            try data?.write(to: url)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
