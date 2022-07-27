//
//  StopAnalyzeMethod.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/07/07.
//

import Foundation

enum StopAnalyzeMethod: String, CaseIterable, Identifiable {
    case forward
    case backward
    
    var id: String { rawValue }
}
