//
//  YochuDetector2Tests.swift
//  YochuDetector2Tests
//
//  Created by Etsushi Otani on 2022/04/18.
//

import XCTest
@testable import YochuDetector2

class YochuDetector2Tests: XCTestCase {
    
    private let areaExtractor = AreaExtractor()

    func testExtractFeed() throws {
        let image = NSImage(named: "yochu_test")!
        let extractedImage = areaExtractor.extractFeed(from: image)
    }
}
