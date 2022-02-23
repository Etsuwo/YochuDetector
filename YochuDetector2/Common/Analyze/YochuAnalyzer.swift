//
//  YochuAnalyzer.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/02/22.
//

import Foundation
import Combine
import AppKit

final class YochuAnalyzer {
    
    private let ciContext = CIContext()
    private let yolo = YOLO()
    private var analyzeInfos: [AnalyzeInfo] = []
    private var activityArray: [[CGRect?]] = []
    let startPublifher = PassthroughSubject<Int, Never>()
    let endPublisher = PassthroughSubject<Void, Never>()
    let progressPublisher = PassthroughSubject<Int, Never>()
    var setting: AnalyzerSetting
    
    init(setting: AnalyzerSetting) {
        self.setting = setting
    }
    
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
    
    /// 検出した矩形がどの試験管のものか解析する
    /// - Parameters:
    ///   - imageWidth: 入力画像幅
    ///   - targetNum: 試験官の数
    ///   - boundingBoxes: 検出した矩形の配列
    /// - Returns: どの試験官に対する矩形か対応関係を持った配列、矩形がない場所はnil
    func assignBoundingBoxes(imageWidth: CGFloat, boundingBoxes: [CGRect]) -> [CGRect?]{
        let step = imageWidth / CGFloat(setting.numberOfTarget)
        var activityList: [CGRect?] = []
        for _ in 0..<setting.numberOfTarget {
            activityList.append(nil)
        }
        boundingBoxes.forEach { boundingBox in
            var left: CGFloat = 0
            var right = step
            for count in 0..<setting.numberOfTarget {
                if left...right ~= boundingBox.midX {
                    activityList[count] = boundingBox
                    break
                }
                left = right
                right += step
            }
        }
        return activityList
    }
}

struct AnalyzeInfo {
    let image: NSImage
    let boundingBoxes: [CGRect]
}
