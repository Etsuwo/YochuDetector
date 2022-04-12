//
//  OpenPanelHandler.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/25.
//

import Foundation
import AppKit

final class OpenPanelHandler {
    func openSelectDirectoryPanel() -> URL? {
        let panel = NSOpenPanel.selectDirectoryPanel()
        if panel.runModal() == .OK {
            return panel.url
        }
        return nil
    }
}
