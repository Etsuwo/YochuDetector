//
//  LoadingViewModel.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/05/31.
//

import Foundation
import Combine

final class LoadingViewModel {
    final class ViewState: ObservableObject {
        @Published var dataSetsCount: Int = 0
        @Published var currentDataSetsCount: Int = 0
        @Published var currentProgressValue: Double = 0
        @Published var totalProgressValue: Double = 0
    }
    
    var viewState = ViewState()
    
    private let analyzer = YochuAnalyzer.shared
    private let dataStore = OneTimeDataStore.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        configure()
        bind()
        startAnlyzer()
    }
    
    private func configure() {
        viewState.dataSetsCount = dataStore.analyzeDatas.count
        viewState.totalProgressValue = Double(dataStore.imageUrls.count)
    }
    
    private func bind() {
        analyzer.progressPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] value in
                self?.viewState.currentProgressValue = value
            })
            .store(in: &cancellables)
    }
    
    func startAnlyzer() {
            DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }
                for (index, data) in strongSelf.dataStore.analyzeDatas.enumerated() {
                    DispatchQueue.main.sync {
                        strongSelf.viewState.currentDataSetsCount = index
                        strongSelf.viewState.currentProgressValue = Double(0)
                    }
                    strongSelf.analyzer.start(with: strongSelf.dataStore.imageUrls, rect: data.croppedRect, numOfTarget: data.numOfTarget, outputSuffix: index, startAt: data.startAt)
//                    strongSelf.analyzer.extract(with: strongSelf.dataStore.imageUrls, rect: rect)
    
            }
            DispatchQueue.main.sync {
                NotificationCenter.default.post(name: .transitionResult, object: nil)
            }
        }
    }
}
