//
//  CSVHandler.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/03/27.
//

import Foundation

final class CSVHandler {
    
    /// csvとして出力する
    /// - Parameters:
    ///   - output: 文字列
    ///   - outputUrl: csvの出力URL
    func write(output: String, to outputUrl: URL) {
        
        let fileName = makeCSVFileName()
        let url = outputUrl.appendingPathComponent(fileName)
        write(data: output, to: url)
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
