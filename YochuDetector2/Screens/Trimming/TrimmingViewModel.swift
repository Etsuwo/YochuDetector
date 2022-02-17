//
//  TrimmingViewModel.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/29.
//

import Foundation
import Combine
import CoreImage
import Vision
import AppKit

final class TrimmingViewModel {
    
    final class ViewState: ObservableObject {
        @Published var url: URL?
        @Published var croppedImage = NSImage()
        @Published var cropViewIsHidden = false
        @Published var croppedViewIsHidden = true
    }
    
    private let dataStore = AnalyzeSettingStore.shared
    private let yolo = YOLO()
    private let ciContext = CIContext()
    private var urls: [URL] = []
    private var nsImage = NSImage()
    private var cropRect = CGRect()
    private var cropViewSize = CGSize()
    
    private(set) var viewState = ViewState()
    
    init() {
        loadImage()
        viewState.url = urls.first
    }
    
    private func loadImage() {
        guard let inputUrl = dataStore.inputUrl else { return }
        do {
            urls = try FileManager.default.contentsOfDirectory(at: inputUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            urls.sort(by: { $0.absoluteString.localizedStandardCompare($1.absoluteString) == ComparisonResult.orderedAscending })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateCropArea(rect: CGRect) {
        cropRect = rect
    }
    
    func updateCropViewSize(size: CGSize) {
        cropViewSize = size
    }
    
    func onTapTrimButton(image: NSImage) {
        let x = cropRect.origin.x * image.size.width / cropViewSize.width
        let y = cropRect.origin.y * image.size.height / cropViewSize.height
        let width = cropRect.size.width * image.size.width / cropViewSize.width
        let height = cropRect.size.height * image.size.height / cropViewSize.height
        viewState.croppedImage = image.crop(to: CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height)))
        viewState.cropViewIsHidden = true
        viewState.croppedViewIsHidden = false
    }
    
    func onTapGoButton() {
        let image = CIImage(contentsOf: urls.first!)!
        let resultImage = image.nsImage
        let scaledImage = image.resizeWithWhiteBackground(context: ciContext, size: CGSize(width: YOLO.inputWidth, height: YOLO.inputHeight))
        
        guard let pixelBuffer = scaledImage.toPixelBuffer(context: ciContext) else { return }
        if let boundingBoxes = try? yolo.predict(image: pixelBuffer) {
            for boundingBox in boundingBoxes {
                // 元画像に矩形を表示するための補正
                let inputSize = resultImage.size.height > resultImage.size.width ? CGSize(width: resultImage.size.width / resultImage.size.height * 640, height: 640) : CGSize(width: 640, height: resultImage.size.height / resultImage.size.width * 640)

                let x = boundingBox.rect.origin.x * resultImage.size.width / inputSize.width
                let y = boundingBox.rect.origin.y * resultImage.size.height / inputSize.height
                let width = boundingBox.rect.width * resultImage.size.width / inputSize.width
                let height = boundingBox.rect.height * resultImage.size.height / inputSize.height
                
                let origin = CGPoint(x: x, y: resultImage.size.height - y - height)
                let size = CGSize(width: width, height: height)
                let rect = CGRect(origin: origin, size: size)
                resultImage.addBoundingRectangle(with: rect)
            }
            AnalyzeSettingStore.shared.analyzedImage = resultImage
            NotificationCenter.default.post(name: .transitionResult, object: nil)
        }
    }
    
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: yolo.model.model) else {
            return
        }
        let request = VNCoreMLRequest(model: visionModel, completionHandler: nil)
        request.imageCropAndScaleOption = .scaleFill
    }
}
