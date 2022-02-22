//
//  YochuAnalyzer.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/02/22.
//

import Foundation
import AppKit

final class YochuAnalyzer {
    static let shared = YochuAnalyzer()
    private init() {}
    
    private let ciContext = CIContext()
    private let yolo = YOLO()
    private var analyzeInfos: [AnalyzeInfo] = []
    
    func start(with urls: [URL], rect: CGRect, completion: (([AnalyzeInfo]) -> Void)) {
        urls.forEach { url in
            let nsImage = NSImage.withOptionalURL(url: url)
            let croppedImage = nsImage.crop(to: rect)
            guard let ciImage = croppedImage.ciImage else { return }
            let scaledImage = ciImage.resizeWithWhiteBackground(context: ciContext, size: CGSize(width: YOLO.inputWidth, height: YOLO.inputHeight))
            guard let pixelBuffer = scaledImage.toPixelBuffer(context: ciContext) else { return }
            if let boundingBoxes = try? yolo.predict(image: pixelBuffer) {
                var modifiedBoundingBoxes: [CGRect] = []
                for boundingBox in boundingBoxes {
                    // 元画像に矩形を表示するための補正
                    let inputSize = croppedImage.size.height > croppedImage.size.width ? CGSize(width: croppedImage.size.width / croppedImage.size.height * 640, height: 640) : CGSize(width: 640, height: croppedImage.size.height / croppedImage.size.width * 640)

                    let x = boundingBox.rect.origin.x * croppedImage.size.width / inputSize.width
                    let y = boundingBox.rect.origin.y * croppedImage.size.height / inputSize.height
                    let width = boundingBox.rect.width * croppedImage.size.width / inputSize.width
                    let height = boundingBox.rect.height * croppedImage.size.height / inputSize.height
                    
                    let origin = CGPoint(x: x, y: croppedImage.size.height - y - height)
                    let size = CGSize(width: width, height: height)
                    let rect = CGRect(origin: origin, size: size)
                    croppedImage.addBoundingRectangle(with: rect)
                    modifiedBoundingBoxes.append(rect)
                }
                analyzeInfos.append(AnalyzeInfo(image: croppedImage, boundingBoxes: modifiedBoundingBoxes))
                completion(analyzeInfos)
            }
        }
    }
}

struct AnalyzeInfo {
    let image: NSImage
    let boundingBoxes: [CGRect]
}
