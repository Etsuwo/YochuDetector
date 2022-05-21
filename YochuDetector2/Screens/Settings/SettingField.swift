//
//  SettingFiled.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/04/25.
//

import SwiftUI

struct SettingField: View {
    let title: String
    let placeholder: String
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            TextField(placeholder, text: $value)
        }
    }
}
