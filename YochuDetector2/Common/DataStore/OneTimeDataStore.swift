//
//  AnalyzeSettingStore.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/29.
//

import Foundation
import AppKit


/// アプリ落としたら消える設定
final class OneTimeDataStore {
    static let shared = OneTimeDataStore()
    private init() {}
    
    var inputUrl: URL?
    var outputUrl: URL?
    var imageUrls: [URL] = []
    var experimentStartAt: Int = 0
    var analyzeDatas: [(Int, CGRect)] = []
}
