//
//  RegisteredAreaView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/05/30.
//

import SwiftUI

struct RegisteredAreaView: View {
    
    @Binding var registerdDatas: [TrimmingViewModel.CroppedData]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(registerdDatas, id: \.id, content: { data in
                    RegisteredAreaCell(numOfTarget: data.numOfTargetInSection, image: data.croppedIcon, onTappedbutton: {
                        registerdDatas.removeAll(where: { $0.id == data.id })
                    })
                })
            }
        }
    }
}

