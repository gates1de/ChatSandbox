//
//  ChatDateHeaderView.swift
//  ChatSandbox
//

import UIKit

internal final class ChatDateHeaderView: UITableViewHeaderFooterView {

    // MARK: - IBOutlets

    @IBOutlet private weak var dateLabel: UILabel!


    // MARK: - Static properties

    static let baseHeight = CGFloat(24.0)


    // MARK: - Internal functions

    func setup(dateString: String) {
        self.dateLabel.text = dateString
    }
}
