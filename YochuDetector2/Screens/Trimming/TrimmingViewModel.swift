//
//  TrimmingViewModel.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/29.
//

import Foundation
import Combine

final class TrimmingViewModel {
    
    final class ViewState: ObservableObject {
        @Published var url: URL?
    }
    
    private let dataStore = AnalyzeSettingStore.shared
    private var urls: [URL] = []
    
    private(set) var viewState = ViewState()
    
    init() {
        loadImage()
        viewState.url = urls.first
    }
    
    private func loadImage() {
        guard let inputUrl = dataStore.inputUrl else { return }
        do {
            urls = try FileManager.default.contentsOfDirectory(at: inputUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            urls.sort(by: { $0.absoluteString.localizedStandardCompare($1.absoluteString) == ComparisonResult.orderedAscending })
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
