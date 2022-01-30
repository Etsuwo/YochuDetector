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
    private var results: [VNClassificationObservation] = []
    
    init() {
        do {
            model = try VNCoreMLModel(for: Yolov3().model)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func sendRequest(ciImage: CIImage) {
        let request = VNCoreMLRequest(model: model) { [weak self] (request, error) in
             // 解析結果を分類情報として保存
             guard let results = request.results as? [VNClassificationObservation] else {
                 return
             }
            self?.results = results
        }
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
}
