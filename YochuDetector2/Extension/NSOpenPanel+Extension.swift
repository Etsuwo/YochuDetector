//
//  NSOpenPanel+Extension.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/25.
//

import Foundation
import AppKit

extension NSOpenPanel {
    static func selectDirectoryPanel() -> NSOpenPanel {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.message = "フォルダを選択してください"
        return openPanel
    }
}
