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
    }
    
    private(set) var viewState = ViewState()
    
    func onTapInputSelectButton() {
        // TODO: 入力フォルダ選択処理
    }
    
    func onTapOutputSelectButton() {
        // TODO: 出力フォルダ選択処理
    }
}
