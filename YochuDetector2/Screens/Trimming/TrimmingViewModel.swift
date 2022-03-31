//
//  TrimmingViewModel.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/29.
//

import Foundation
import Combine
import CoreImage
import Vision
import AppKit

final class TrimmingViewModel {
    
    final class ViewState: ObservableObject {
        @Published var url: URL?
        @Published var croppedImage = NSImage()
        @Published var cropViewIsHidden = false
        @Published var croppedViewIsHidden = true
        @Published var numOfTargetInSection = "0"
        @Published var currentProgressValue = 0.0
        @Published var totalProgressValue = 0.0
        @Published var isHiddenProgressView = true
    }
    
    private let dataStore = AnalyzeSettingStore.shared
    private let analyzer = YochuAnalyzer(setting: AnalyzerSetting())
    private var cancellables = Set<AnyCancellable>()
    private var urls: [URL] = []
    private var cropRect = CGRect()
    private var cropViewSize = CGSize()
    private var modifiedRect = CGRect()
    
    private(set) var viewState = ViewState()
    
    init() {
        loadImage()
        viewState.url = urls.first
        bind()
    }
    
    private func bind() {
        analyzer.progressPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &viewState.$currentProgressValue)
        analyzer.endPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] infos in
                self?.viewState.isHiddenProgressView = true
                AnalyzeSettingStore.shared.analyzeInfos = infos
                NotificationCenter.default.post(name: .transitionResult, object: nil)
            })
            .store(in: &cancellables)
    }
    
    private func loadImage() {
        guard let inputUrl = dataStore.inputUrl else { return }
        do {
            urls = try FileManager.default.contentsOfDirectory(at: inputUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            urls.sort(by: { $0.absoluteString.localizedStandardCompare($1.absoluteString) == ComparisonResult.orderedAscending })
            viewState.totalProgressValue = Double(urls.count)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateCropArea(rect: CGRect) {
        cropRect = rect
    }
    
    func updateCropViewSize(size: CGSize) {
        cropViewSize = size
    }
    
    func onTapTrimButton(image: NSImage) {
        let x = cropRect.origin.x * image.size.width / cropViewSize.width
        let y = cropRect.origin.y * image.size.height / cropViewSize.height
        let width = cropRect.size.width * image.size.width / cropViewSize.width
        let height = cropRect.size.height * image.size.height / cropViewSize.height
        modifiedRect = CGRect(x: x, y: y, width: width, height: height)
        viewState.croppedImage = image.crop(to: CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height)))
        viewState.cropViewIsHidden = true
        viewState.croppedViewIsHidden = false
    }
    
    func onTapReturnButton() {
        viewState.cropViewIsHidden = false
        viewState.croppedViewIsHidden = true
    }
    
    func onTapGoButton() {
        guard let numOfTarget = Int(viewState.numOfTargetInSection) else { return } // TODO: エラー処理
        viewState.isHiddenProgressView = false
        analyzer.setting = AnalyzerSetting(numberOfTarget: numOfTarget)
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.analyzer.start(with: strongSelf.urls, rect: strongSelf.modifiedRect)
            //strongSelf.analyzer.crop(with: strongSelf.urls, rect: strongSelf.modifiedRect)
        }
    }
}
