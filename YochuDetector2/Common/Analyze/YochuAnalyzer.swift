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
    
    static let shared = YochuAnalyzer()
    private init() {}
    
    private let ciContext = CIContext()
    private let yolo = YOLO()
    private var activityArray: [[CGRect?]] = []
    private let imageSaver = ImageSaver()
    private let areaExtractor = AreaExtractor()
    private let dataStore = AnalyzeDataStore()
    let endPublisher = PassthroughSubject<Void, Never>()
    let progressPublisher = PassthroughSubject<Double, Never>()
    var setting: AnalyzerSetting { AnalyzeSettingStore.shared.analyzerSetting }
    
    // 作業用
    func crop(with urls: [URL], rect: CGRect) {
        for (index ,url) in urls.enumerated() {
            let nsImage = NSImage.withOptionalURL(url: url)
            let cropImage = nsImage.crop(to: rect)
            //let extractedImage = AreaExtractor().extractFeed(from: cropImage)
            imageSaver.save(image: cropImage, fileName: url.lastPathComponent, to: AnalyzeSettingStore.shared.outputUrl!)
            progressPublisher.send(Double(index + 1))
        }
        endPublisher.send()
    }
    
    func extract(with urls: [URL]) {
        //for threshold in 20...40 {
            let output = AnalyzeSettingStore.shared.outputUrl?.appendingPathComponent("extract")
            try! FileManager.default.createDirectory(at: output!, withIntermediateDirectories: true, attributes: nil)
            for (index ,url) in urls.enumerated() {
                autoreleasepool {
                    let nsImage = NSImage.withOptionalURL(url: url)
                    //let cropImage = nsImage.crop(to: rect)
                    let extractedImage = AreaExtractor().extractFeed(from: nsImage, binaryThreshold: 20)
                    imageSaver.save(image: extractedImage, fileName: url.lastPathComponent, to: output!)
                    progressPublisher.send(Double(index + 1))
                }
            }
       // }
        endPublisher.send()
    }
    
    func start(with urls: [URL], rect: CGRect, numOfTarget: Int) {
        for (index, url) in urls.enumerated() {
            autoreleasepool {
                let nsImage = NSImage.withOptionalURL(url: url)
                let croppedImage = nsImage.crop(to: rect)
                let sourceImage = areaExtractor.extractFeed(from: croppedImage, binaryThreshold: Double(setting.binaryThreshold))
                guard let ciImage = sourceImage.ciImage else { return }
                yolo.predict(image: ciImage) { [weak self, weak croppedImage] observations in
                    guard let strongSelf = self,
                          let strongCroppedImage = croppedImage else { return }
                    var modifiedBoundingBoxes: [CGRect] = []
                    for observation in observations {
                        let boudingBox = observation.boundingBox
                        let origin = CGPoint(x: boudingBox.origin.x * strongCroppedImage.size.width, y: boudingBox.origin.y * strongCroppedImage.size.height)
                        let size = CGSize(width: boudingBox.size.width * strongCroppedImage.size.width, height: boudingBox.size.height * strongCroppedImage.size.height)
                        let rect = CGRect(origin: origin, size: size)
                        strongCroppedImage.addBoundingRectangle(with: rect)
                        modifiedBoundingBoxes.append(rect)
                    }
                    let outputURL = strongSelf.imageSaver.save(image: strongCroppedImage, fileName: url.lastPathComponent, to: AnalyzeSettingStore.shared.outputUrl!)
                    let separatedBoudingBoxes = strongSelf.assignBoundingBoxes(imageWidth: strongCroppedImage.size.width, boundingBoxes: modifiedBoundingBoxes, numberOfTarget: numOfTarget)
                    strongSelf.dataStore.register(imageURL: outputURL, boudingBoxes: separatedBoudingBoxes)
                }
                progressPublisher.send(Double(index + 1))
            }
        }
        analyze()
        CSVHandler().write(resultDatas: dataStore.resultDatas, to: AnalyzeSettingStore.shared.outputUrl!)
        endPublisher.send()
    }
    
    /// 検出した矩形がどの試験管のものか解析する
    /// - Parameters:
    ///   - imageWidth: 入力画像幅
    ///   - targetNum: 試験官の数
    ///   - boundingBoxes: 検出した矩形の配列
    /// - Returns: どの試験官に対する矩形か対応関係を持った配列、矩形がない場所はnil
    func assignBoundingBoxes(imageWidth: CGFloat, boundingBoxes: [CGRect], numberOfTarget: Int) -> [CGRect?]{
        let step = imageWidth / CGFloat(numberOfTarget)
        var activityList: [CGRect?] = []
        for _ in 0..<numberOfTarget {
            activityList.append(nil)
        }
        boundingBoxes.forEach { boundingBox in
            var left: CGFloat = 0
            var right = step
            for count in 0..<numberOfTarget {
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
