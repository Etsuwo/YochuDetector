//
//  Hidden.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/02/17.
//

import Foundation
import SwiftUI

struct Hidden: ViewModifier {
    let hidden: Bool
    
    func body(content: Content) -> some View {
        if !hidden {
            content
        }
    }
}

extension View {
    func isHidden(_ isHidden: Bool) -> some View {
        ModifiedContent(content: self, modifier: Hidden(hidden: isHidden))
    }
}
