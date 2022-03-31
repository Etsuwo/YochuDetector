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
    private let imageSaver = ImageSaver()
    private let dataStore = AnalyzeDataStore()
    let endPublisher = PassthroughSubject<[AnalyzeInfo], Never>()
    let progressPublisher = PassthroughSubject<Double, Never>()
    var setting: AnalyzerSetting
    
    init(setting: AnalyzerSetting) {
        self.setting = setting
    }
    
    // 作業用
    func crop(with urls: [URL], rect: CGRect) {
        for (index ,url) in urls.enumerated() {
            let nsImage = NSImage.withOptionalURL(url: url)
            let cropImage = nsImage.crop(to: rect)
            imageSaver.save(image: cropImage, fileName: url.lastPathComponent, to: AnalyzeSettingStore.shared.outputUrl!)
            progressPublisher.send(Double(index + 1))
        }
        endPublisher.send(analyzeInfos)
    }
    
    func start(with urls: [URL], rect: CGRect) {
        for (index, url) in urls.enumerated() {
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
                let outputURL = imageSaver.save(image: croppedImage, fileName: url.lastPathComponent, to: AnalyzeSettingStore.shared.outputUrl!)
                let separatedBoudingBoxes = assignBoundingBoxes(imageWidth: croppedImage.size.width, boundingBoxes: modifiedBoundingBoxes)
                dataStore.register(imageURL: outputURL, boudingBoxes: separatedBoudingBoxes)
                //analyzeInfos.append(AnalyzeInfo(image: croppedImage, boundingBoxes: modifiedBoundingBoxes))
            }
            progressPublisher.send(Double(index + 1))
        }
        analyze()
        CSVHandler().write(resultDatas: dataStore.resultDatas, to: AnalyzeSettingStore.shared.outputUrl!)
        endPublisher.send(analyzeInfos)
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
    
    private func analyze() {
        let detectedDatas = dataStore.trnseposeActivitiesData
        for (index, detectedData) in detectedDatas.enumerated() {
            let startAt = analyzeWandaring(detectedData: detectedData)
            let stopAt = analyzeStop(detectedData: detectedData)
            dataStore.register(wadaringAt: startAt, stopAt: stopAt, boundingBoxes: detectedData)
        }
    }
    
    /// ワンダリング行動の検出
    /// - Parameter detectedData: 幼虫一匹分の行動データ配列
    /// - Returns: ワンダリング行動のスタート時間（単位は分）、してなかったらnil
    private func analyzeWandaring(detectedData: [CGRect?]) -> Int? {
        let experimentHours = detectedData.count / setting.oneHour
        var preSectionTotal = 0
        var firstSectionTotal = 0
        var secondSectionTotal = 0
        
        for hour in 0..<experimentHours {
            let start = hour * setting.oneHour
            preSectionTotal = firstSectionTotal
            firstSectionTotal = secondSectionTotal
            let secondSection = detectedData[start ..< start + setting.oneHour]
            secondSectionTotal = secondSection.reduce(into: 0) {
                $0 += $1 != nil ? 1 : 0
            }
            if firstSectionTotal >= setting.wandaringThreshold,
               secondSectionTotal >= setting.wandaringThreshold {
                return calcWandaringStart(preSectionTotal, firstSectionTotal, preStart: (hour - 2) * 60)
            }
        }
        return nil
    }
    
    private func calcWandaringStart(_ preSectionTotal: Int, _ firstSectionTotal: Int, preStart: Int) -> Int {
        (setting.wandaringThreshold - preSectionTotal) * (60 / (firstSectionTotal - preSectionTotal)) + preStart
    }
    
    /// ワンダリング行動の停止時間の算出
    /// - Parameter detectedData: 幼虫一匹の行動データ配列
    /// - Returns: 終了時間、単位は分、止まってなかったらnil
    private func analyzeStop(detectedData: [CGRect?]) -> Int? {
        for (index, rect) in detectedData.enumerated() {
            if index + setting.stopThreshold > detectedData.count {
                break
            }
            
            if let rect = rect {
                for count in 1...setting.stopThreshold {
                    if count == setting.stopThreshold {
                        return index * setting.interval
                    }
                    if let compareRect = detectedData[index + count] {
                        let buffer = CGFloat(setting.stopRectBuffer)
                        let xRange = rect.midX - buffer ... rect.midX + buffer
                        let yRange = rect.midY - buffer ... rect.midY + buffer
                        
                        if !xRange.contains(compareRect.midX) ||
                            !yRange.contains(compareRect.midY) {
                            break   // まだ動いてる
                        }
                    } else { break }
                }
            }
        }
        
        return nil // 止まってない
    }
}

struct AnalyzeInfo {
    let image: NSImage
    let boundingBoxes: [CGRect]
}
