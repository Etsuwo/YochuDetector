//
//  YOLO.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/30.

import Foundation
import CoreML
import Vision
import CoreImage

class YOLO {
    public static let inputWidth = 640
    public static let inputHeight = 640
    public static let maxBoundingBoxes = 10

      // Tweak these values to get more or fewer predictions.
    let confidenceThreshold: Float = 0.1
    let iouThreshold: Float = 0.2

    private let model = try! VNCoreMLModel(for: Yolov5().model)
    
    func predict(image: CIImage, completion: @escaping ([VNRecognizedObjectObservation]) -> Void) {
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let observations = request.results as? [VNRecognizedObjectObservation] else { return }
            completion(observations)
        }
        request.imageCropAndScaleOption = .scaleFit
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
