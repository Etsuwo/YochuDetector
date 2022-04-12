//
//  RootView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/27.
//

import SwiftUI
import Combine

struct RootView: View {
    
    private let viewModel = RootViewModel()
    @ObservedObject var viewState: RootViewModel.ViewState
    
    init() {
        viewState = viewModel.viewState
    }
    
    var body: some View {
        switch viewState.displayView {
        case .selectSource: SelectSourceView()
        case .trimming: TrimmingView()
        case .result: ResultView()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
