//
//  SelectSourceViewModel.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/22.
//

import Foundation
import Combine

final class SelectSourceViewModel {
    final class ViewState: ObservableObject {
        @Published var inputDirectory: String = ""
        @Published var outputDirectory: String = ""
        @Published var onTransitionTrimmingView = false
        @Published var isActiveNextButton = false
    }
    
    private(set) var viewState = ViewState()
    private let panelHandler = OpenPanelHandler()
    
    func onTapInputSelectButton() {
        let url = panelHandler.openSelectDirectoryPanel()
        viewState.inputDirectory = url?.absoluteString ?? ""
        viewState.isActiveNextButton = viewState.inputDirectory.isNotEmpty && viewState.outputDirectory.isNotEmpty
    }
    
    func onTapOutputSelectButton() {
        let url = panelHandler.openSelectDirectoryPanel()
        viewState.outputDirectory = url?.absoluteString ?? ""
        viewState.isActiveNextButton = viewState.inputDirectory.isNotEmpty && viewState.outputDirectory.isNotEmpty
    }
}
