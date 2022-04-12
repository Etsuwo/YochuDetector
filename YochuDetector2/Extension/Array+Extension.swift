//
//  Array+Extension.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/02/23.
//

import Foundation

extension Array where Element: RandomAccessCollection, Element.Index == Int {
    func transpose() -> [[Element.Element]] {
        return self.isEmpty ? [] : (0...(self.first!.endIndex - 1)).map { i -> [Element.Element] in self.map { $0[i] } }
    }
}
