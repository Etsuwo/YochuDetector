//
//  UnInteractiveLoadingView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/04/14.
//

import SwiftUI

struct LoadingView: View {
    
    private let viewModel = LoadingViewModel()
    @ObservedObject var viewState: LoadingViewModel.ViewState
    
    init() {
        viewState = viewModel.viewState
    }
    
    
    var body: some View {
        ZStack {
            ProgressView("Analyzing... \(viewState.currentDataSetsCount)/\(viewState.dataSetsCount)", value: viewState.currentProgressValue, total: viewState.totalProgressValue)
                .frame(maxWidth: .infinity)
                .padding()
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


