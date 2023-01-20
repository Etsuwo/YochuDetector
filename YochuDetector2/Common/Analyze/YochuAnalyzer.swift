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
    private let imageSaver = ImageSaver()
    private let directoryHandler = DirectoryHandler()
    private let areaExtractor = AreaExtractor()
    private let dataStore = AnalyzeDataStore()
    let endPublisher = PassthroughSubject<Void, Never>()
    let progressPublisher = PassthroughSubject<Double, Never>()
    private let oneTimeDataStore = OneTimeDataStore.shared
    private let permanentDataStore = PermanentDataStore()
    
    // 作業用
    func crop(with urls: [URL], rect: CGRect) {
        for (index ,url) in urls.enumerated() {
            let nsImage = NSImage.withOptionalURL(url: url)
            let cropImage = nsImage.crop(to: rect)
            let extractedImage = AreaExtractor().extractFeed(from: cropImage)
            imageSaver.save(image: extractedImage, fileName: url.lastPathComponent, to: OneTimeDataStore.shared.outputUrl!)
            progressPublisher.send(Double(index + 1))
        }
        endPublisher.send()
    }
    
    func extract(with urls: [URL], rect: CGRect) {
            let output = OneTimeDataStore.shared.outputUrl?.appendingPathComponent("extract")
            try! FileManager.default.createDirectory(at: output!, withIntermediateDirectories: true, attributes: nil)
            for (index ,url) in urls.enumerated() {
                autoreleasepool {
                    let nsImage = NSImage.withOptionalURL(url: url)
                    let cropImage = nsImage.crop(to: rect)
                    let extractedImage = AreaExtractor().extractFeed(from: cropImage, binaryThreshold: 20)
                    imageSaver.save(image: extractedImage, fileName: url.lastPathComponent, to: output!)
                    progressPublisher.send(Double(index + 1))
                }
            }
        endPublisher.send()
    }
    
    func start(with urls: [URL], rect: CGRect, numOfTarget: Int, outputSuffix: Int, startAt: Int) {
        dataStore.flash()
        let outputDirectoryURL = directoryHandler.createDirectory(directoryName: "output_\(outputSuffix)", to: oneTimeDataStore.outputUrl!)
        for (index, url) in urls.enumerated() {
            autoreleasepool {
                let nsImage = NSImage.withOptionalURL(url: url)
                let croppedImage = nsImage.crop(to: rect)
                let sourceImage = areaExtractor.extractFeed(from: croppedImage, binaryThreshold: Double(permanentDataStore.binaryThreshold))
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
                    let outputURL = strongSelf.imageSaver.save(image: strongCroppedImage, fileName: url.lastPathComponent, to: outputDirectoryURL)
                    let separatedBoudingBoxes = strongSelf.assignBoundingBoxes(imageWidth: strongCroppedImage.size.width, boundingBoxes: modifiedBoundingBoxes, numberOfTarget: numOfTarget)
                    strongSelf.dataStore.register(imageURL: outputURL, boudingBoxes: separatedBoudingBoxes)
                }
                progressPublisher.send(Double(index + 1))
            }
        }
        analyze(experimentStartAt: startAt)
        let output = ResultDataConverter().toCSVFormat(from: dataStore.resultDatas, startAt: startAt)
        CSVHandler().write(output: output, to: outputDirectoryURL)
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
    
    private func analyze(experimentStartAt: Int) {
        let detectedDatas = dataStore.trnseposeActivitiesData
        for detectedData in detectedDatas {
            let startAt = analyzeWandaring(detectedData: detectedData, startAt: experimentStartAt)
            var stopAt: Int? = nil
            switch permanentDataStore.stopAnalyzeMethod {
            case .forward:
                stopAt = analyzeStopFromForward(detectedData: detectedData, stopThreshold: permanentDataStore.stopThreshold, buffer: CGFloat(permanentDataStore.stopRectBuffer), interval: permanentDataStore.interval, experimentStartAt: experimentStartAt)
            case .backward:
                stopAt = analyzeStopFromBackward(detectedData: detectedData, stopThreshold: permanentDataStore.stopThreshold, buffer: CGFloat(permanentDataStore.stopRectBuffer), interval: permanentDataStore.interval, experimentStartAt: experimentStartAt)
            }
            dataStore.register(wadaringAt: startAt, stopAt: stopAt, boundingBoxes: detectedData)
        }
    }
    
    /// ワンダリング行動の検出
    /// - Parameter detectedData: 幼虫一匹分の行動データ配列
    /// - Returns: ワンダリング行動のスタート時間（単位は分）、してなかったらnil
    private func analyzeWandaring(detectedData: [CGRect?], startAt: Int) -> Int? {
        let experimentHours = detectedData.count / permanentDataStore.oneHour
        var preSectionTotal = 0
        var firstSectionTotal = 0
        var secondSectionTotal = 0
        
        for hour in 0..<experimentHours {
            let start = hour * permanentDataStore.oneHour
            preSectionTotal = firstSectionTotal
            firstSectionTotal = secondSectionTotal
            let secondSection = detectedData[start ..< start + permanentDataStore.oneHour]
            secondSectionTotal = secondSection.reduce(into: 0) {
                $0 += $1 != nil ? 1 : 0
            }
            if firstSectionTotal >= permanentDataStore.wandaringThreshold,
               secondSectionTotal >= permanentDataStore.wandaringThreshold {
                return calcWandaringStart(preSectionTotal, firstSectionTotal, preStart: (hour - 2) * 60, experimentStartAt: startAt)
            }
        }
        return nil
    }
    
    private func calcWandaringStart(_ preSectionTotal: Int, _ firstSectionTotal: Int, preStart: Int, experimentStartAt: Int) -> Int {
        (permanentDataStore.wandaringThreshold - preSectionTotal) * (60 / (firstSectionTotal - preSectionTotal)) + preStart + experimentStartAt
    }
    
    /// ワンダリング行動の停止時間の算出、後ろから座標を確認する
    /// - Parameters:
    ///   - detectedData: 幼虫一匹分の行動データの配列
    ///   - stopThreshold: 停止時間の閾値
    ///   - buffer: 許容誤差
    ///   - interval: 何分ごとに画像が撮影されているか
    /// - Returns: 止まってたら停止した時間(分)、止まってないならnil
    private func analyzeStopFromBackward(detectedData: [CGRect?], stopThreshold: Int, buffer: CGFloat, interval: Int, experimentStartAt: Int) -> Int? {
        let reverseData: [CGRect?] = detectedData.reversed()
        var stopFlag = false
        var nilFlag = false
        var currentIndex = 0
        guard let lastElement = reverseData.first,
              let lastRect = lastElement else { return nil } // 最終座標なし
        for (index, rect) in reverseData.enumerated() {
            if let rect = rect {
                if rect.isSameCenter(at: lastRect, buffer: buffer) {
                    if index + 1 > stopThreshold {
                        stopFlag = true
                        currentIndex = index
                    } // 一定時間経過で停止してると判定
                    nilFlag = false
                    continue // 止まってる
                } else {
                    break // 動いた
                }
            } else {
                if nilFlag {
                    break // 二連続nil
                } else {
                    nilFlag = true
                    continue // 一度なら検知漏れをスルー
                }
            }
        }
        let stopAt = (detectedData.endIndex - currentIndex) * interval + experimentStartAt
        return stopFlag ? stopAt : nil
    }
    
    /// ワンダリング行動の停止時間の算出、前から座標を確認する
    /// - Parameters:
    ///   - detectedData: 幼虫一匹分の行動データの配列
    ///   - stopThreshold: 停止時間の閾値
    ///   - buffer: 許容誤差
    ///   - interval: 何分ごとに画像が撮影されているか
    /// - Returns: 止まってたら停止した時間(分)、止まってないならnil
    private func analyzeStopFromForward(detectedData: [CGRect?], stopThreshold: Int, buffer: CGFloat, interval: Int, experimentStartAt: Int) -> Int? {
        var nilFlag = false
        for (index, rect) in detectedData.enumerated() {
            if index + stopThreshold > detectedData.count {
                break // データを全部見切った
            }
            
            if let rect = rect {
                for count in 1...stopThreshold {
                    if count == stopThreshold {
                        return index * interval + experimentStartAt // 止まってる
                    }
                    if let compareRect = detectedData[index + count] {
                        nilFlag = false
                        if compareRect.isSameCenter(at: rect, buffer: buffer) {
                            
                            continue // 同じ座標
                        } else {
                            break // 動いた
                        }
                    } else {
                        if nilFlag {
                            nilFlag = false
                            break // ２度は許さん
                        } else {
                            nilFlag = true
                            continue // 一度なら検知漏れをスルー
                        }
                    }
                }
            }
        }
        return nil // 止まってない
    }
}
