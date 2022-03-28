//
//  CSVHandler.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/03/27.
//

import Foundation

final class CSVHandler {
    
    /// 幼虫の検出位置をcsvとして出力する
    /// - Parameters:
    ///   - resultDatas: 解析結果データの配列
    ///   - outputUrl: csvの出力URL
    func write(resultDatas: [AnalyzeDataStore.ResultData], to outputUrl: URL) {
        guard !resultDatas.isEmpty else { fatalError() }
        var outputString = ""
        
        // ヘッダー作成
        outputString += ","
        for count in 1 ... resultDatas[0].boundingBoxes.count {
            outputString += "\(DateComponentsFormatter.headerString(from: Double(count * 2 * 60))),"
        }
        outputString += "\n"
        
        // 本体作成
        for (index, resultData) in resultDatas.enumerated() {
            let joinedString = resultData.boundingBoxes.map {
                $0 != nil ? String(format:"(%.1f %.1f)", $0!.midX, $0!.midY) : ""
            }.joined(separator: ",")
            outputString += "\(index + 1),\(joinedString)\n"
        }
        let fileName = makeCSVFileName()
        let url = outputUrl.appendingPathComponent(fileName)
        write(data: outputString, to: url)
    }
    
    private func makeCSVFileName() -> String {
        "location_\(Date.nowString()).csv"
    }
    
    private func write(data: String, to outputUrl: URL) {
        do {
            try data.write(to: outputUrl, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
