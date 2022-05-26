//
//  ResultDataConverter.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/05/26.
//

import Foundation

final class ResultDataConverter {
    func toCSVFormat(from resultDatas: [AnalyzeDataStore.ResultData], startAt: Int) -> String {
        guard !resultDatas.isEmpty else { fatalError() }
        var outputString = ""
        // ヘッダー作成
        outputString += ",wandaringAt,stopAt,"
        for count in 0 ..< resultDatas[0].boundingBoxes.count {
            outputString += "\(DateComponentsFormatter.headerString(from: Double((count * 2 + startAt) * 60))),"
        }
        outputString += "\n"
        
        // 本体作成
        for (index, resultData) in resultDatas.enumerated() {
            let joinedString = resultData.boundingBoxes.map {
                $0 != nil ? String(format:"(%.1f %.1f)", $0!.midX, $0!.midY) : ""
            }.joined(separator: ",")
            let wandaringAt = Double(resultData.wandaringAt ?? 0).minuteToHour
            let stopAt = Double(resultData.stopAt ?? 0).minuteToHour
            outputString += "\(index + 1),\(wandaringAt),\(stopAt),\(joinedString),\n"
        }
        
        return outputString
    }
}
