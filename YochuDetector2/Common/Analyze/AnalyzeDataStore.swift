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
    private var resultDatas: [ResultData] = []
    
    var trnseposeActivitiesData: [[CGRect?]] {
        let activitiesData = analyzedDatas.reduce(into: []) {
            $0.append($1.boundingBoxes)
        }
        return activitiesData.transpose()
    }
    
    /// 写真ごとのデータを保持
    struct AnalyzedData {
        let image: NSImage
        let boundingBoxes: [CGRect?]
    }
    
    /// 幼虫ごとのデータを保持
    struct ResultData {
        let wandaringAt: Int?
        let stopAt: Int?
        let boundingBoxes: [CGRect?]
    }
    
    func register(image: NSImage, boudingBoxes: [CGRect?]) {
        analyzedDatas.append(AnalyzedData(image: image, boundingBoxes: boudingBoxes))
    }
    
    func register(wadaringAt: Int?, stopAt: Int?, boundingBoxes: [CGRect?]) {
        resultDatas.append(ResultData(wandaringAt: wadaringAt, stopAt: stopAt, boundingBoxes: boundingBoxes))
    }
}
