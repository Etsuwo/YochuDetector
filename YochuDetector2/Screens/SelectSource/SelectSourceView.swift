//
//  ContentView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/22.
//

import SwiftUI

struct SelectSourceView: View {
    private let viewModel = SelectSourceViewModel()
    @ObservedObject private var viewState: SelectSourceViewModel.ViewState
    
    init() {
        self.viewState = viewModel.viewState
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text("Input Source")
                    .padding(.horizontal)
                Spacer()
            }
            HStack {
                TextField("入力フォルダを選んでね", text: $viewState.inputDirectory)
                Button(action: {
                    viewModel.onTapInputSelectButton()
                }, label: {
                    Text("select")
                })
            }
            Spacer()
                .frame(height: 24)
            HStack {
                Text("Input Source")
                    .padding(.horizontal)
                Spacer()
            }
            HStack {
                TextField("出力フォルダを選んでね", text: $viewState.outputDirectory)
                Button(action: {
                    viewModel.onTapOutputSelectButton()
                }, label: {
                    Text("select")
                })
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    // TODO: 画面遷移
                }, label: {
                    Text("Next")
                })
            }
            Spacer()
                .frame(height: 24)
        }
        .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SelectSourceView()
    }
}