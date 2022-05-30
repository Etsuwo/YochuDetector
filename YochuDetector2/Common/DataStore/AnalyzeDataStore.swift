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
    private(set) var resultDatas: [ResultData] = []
    
    var trnseposeActivitiesData: [[CGRect?]] {
        let activitiesData = analyzedDatas.reduce(into: []) {
            $0.append($1.boundingBoxes)
        }
        return activitiesData.transpose()
    }
    
    /// 写真ごとのデータを保持
    struct AnalyzedData {
        let imageURL: URL
        let boundingBoxes: [CGRect?]
    }
    
    /// 幼虫ごとのデータを保持
    struct ResultData {
        let wandaringAt: Int?
        let stopAt: Int?
        let boundingBoxes: [CGRect?]
    }
    
    func register(imageURL: URL, boudingBoxes: [CGRect?]) {
        analyzedDatas.append(AnalyzedData(imageURL: imageURL, boundingBoxes: boudingBoxes))
    }
    
    func register(wadaringAt: Int?, stopAt: Int?, boundingBoxes: [CGRect?]) {
        resultDatas.append(ResultData(wandaringAt: wadaringAt, stopAt: stopAt, boundingBoxes: boundingBoxes))
    }
    
    /// データの消去
    func flash() {
        analyzedDatas = []
        resultDatas = []
    }
}
