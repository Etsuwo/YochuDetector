//
//  AnalyzeDataStore.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/03/27.
//

import Foundation
import AppKit

final class AnalyzeDataStore {
    
    private var analyzedDatas: [AnalyzedData] = []
    
    struct AnalyzedData {
        let image: NSImage
        let boundingBoxes: [CGRect?]
    }
    
    func register(image: NSImage, boudingBoxes: [CGRect?]) {
        analyzedDatas.append(AnalyzedData(image: image, boundingBoxes: boudingBoxes))
    }
}
