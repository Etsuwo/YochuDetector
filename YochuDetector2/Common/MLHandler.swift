//
//  MLHandler.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/30.
//

import Foundation
import CoreML
import Vision
import CoreImage

final class MLHandler {
    
    private let model: VNCoreMLModel
    private var results: [VNCoreMLFeatureValueObservation] = []
    private let yolo = YOLO()
    
    init() {
        do {
            model = try VNCoreMLModel(for: yolo.model.model)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func sendRequest(ciImage: CIImage) {
        let request = VNCoreMLRequest(model: model) { [weak self] (request, error) in
             // 解析結果を分類情報として保存
            var array: [MLMultiArray] = []
             guard let results = request.results as? [VNCoreMLFeatureValueObservation] else {
                 return
             }
            self?.results = results
            for result in results {
                guard let value = result.featureValue.multiArrayValue else { return }
                array.append(value)
            }
            var image = ciImage.nsImage
            guard let boundingBoxes = self?.yolo.computeBoundingBoxes(features: array) else { return }
                for boundingBox in boundingBoxes {
                    let inputSize = ciImage.extent.height > ciImage.extent.width ? CGSize(width: ciImage.extent.width / ciImage.extent.height * 640, height: 640) : CGSize(width: 640, height: ciImage.extent.height / ciImage.extent.width * 640)
    
                    let x = boundingBox.rect.origin.x * ciImage.extent.width / inputSize.width
                    let y = boundingBox.rect.origin.y * ciImage.extent.height / inputSize.height
                    let width = boundingBox.rect.width * ciImage.extent.width / inputSize.width
                    let height = boundingBox.rect.height * ciImage.extent.height / inputSize.height
                    let modifiedRect = CGRect(x: x , y: y, width: width, height: height)
                    image.addBoundingRectangle(with: modifiedRect)
                }
            AnalyzeSettingStore.shared.analyzedImage = image
            NotificationCenter.default.post(name: .transitionResult, object: nil)
        }
    
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
}
