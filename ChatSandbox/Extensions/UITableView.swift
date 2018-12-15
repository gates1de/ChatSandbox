//
//  UITableView.swift
//  ChatSandbox
//

import UIKit

extension UITableView {

    func scrollToBottom(animated: Bool = true) {
        let numberOfSections = self.numberOfSections
        guard numberOfSections > 0 else { return }

        let targetSection = numberOfSections - 1
        let numberOfRows  = self.numberOfRows(inSection: targetSection)
        guard numberOfRows > 0 else { return }

        let targetRow       = numberOfRows - 1
        let targetIndexPath = IndexPath(row: targetRow, section: targetSection)

        self.scrollToRow(at: targetIndexPath, at: .bottom, animated: animated)
    }
}
