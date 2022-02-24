//
//  ResultView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/31.
//

import SwiftUI

struct ResultView: View {
    let viewModel = ResultViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            Text("Complete")
                .font(.title)
                .padding()
            Text("Outputに指定したフォルダから解析結果を確認してください")
            Spacer()
            Button(action: {
                viewModel.onTapBackTrimming()
            }, label: {
                Text("トリミングへ戻る")
            })
                .padding()
        }
        .frame(minWidth: 200, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView()
    }
}
