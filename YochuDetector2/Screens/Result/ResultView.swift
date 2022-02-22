//
//  ResultView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/31.
//

import SwiftUI

struct ResultView: View {
    let store = AnalyzeSettingStore.shared
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                Image(nsImage: store.analyzeInfos[0].image)
                Image(nsImage: store.analyzeInfos[1].image)
                Image(nsImage: store.analyzeInfos[2].image)
            }
        }
        .frame(height: 800)
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView()
    }
}
