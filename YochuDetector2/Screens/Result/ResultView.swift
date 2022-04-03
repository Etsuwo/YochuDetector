//
//  ResultView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/31.
//

import SwiftUI

struct ResultView: View {
    var body: some View {
        Image(nsImage: AnalyzeSettingStore.shared.analyzedImage!)
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView()
    }
}
