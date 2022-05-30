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

protocol TrimmingViewState: UnInteractiveLoadingViewState, ObservableObject {}

final class TrimmingViewModel {
    
    final class ViewState: TrimmingViewState {
        @Published var url: URL?
        @Published var croppedImage = NSImage()
        @Published var cropViewIsHidden = false
        @Published var croppedViewIsHidden = true
        @Published var numOfTargetInSection = 1
        @Published var experimentStartAt = 0
        @Published var currentProgressValue = 0.0
        @Published var totalProgressValue = 0.0
        @Published var isHiddenProgressView = true
        @Published var registeredDatas: [CroppedData] = []
    }
    
    struct CroppedData: Identifiable {
        let id = UUID()
        let numOfTargetInSection: Int
        let croppedRect: CGRect
        let croppedIcon: NSImage
    }
    
    private let dataStore = OneTimeDataStore.shared
    private let analyzer = YochuAnalyzer.shared
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
        viewState.experimentStartAt = dataStore.experimentStartAt
    }
    
    private func bind() {
        analyzer.progressPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &viewState.$currentProgressValue)
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
    
    func onTapRegisterButton() {
        let data = CroppedData(numOfTargetInSection: viewState.numOfTargetInSection, croppedRect: modifiedRect, croppedIcon: viewState.croppedImage)
        viewState.registeredDatas.append(data)
        viewState.cropViewIsHidden = false
        viewState.croppedViewIsHidden = true
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
        dataStore.experimentStartAt = viewState.experimentStartAt
        viewState.isHiddenProgressView = false
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }
            for (index, data) in strongSelf.viewState.registeredDatas.enumerated() {
                strongSelf.analyzer.start(with: strongSelf.urls, rect: data.croppedRect, numOfTarget: data.numOfTargetInSection, outputSuffix: index)
            }
            DispatchQueue.main.async {
                self?.viewState.isHiddenProgressView = true
                NotificationCenter.default.post(name: .transitionResult, object: nil)
            }
        }
    }
    
    func onTapBackToTopButton() {
        NotificationCenter.default.post(name: .transitionSelectSource, object: nil)
    }
    
    func onTapGoSettingsButton() {
        NotificationCenter.default.post(name: .transitionSettings, object: nil)
    }
}
