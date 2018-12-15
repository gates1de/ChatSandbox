//
//  SystemMessageTableViewCell.swift
//  ChatSandbox
//

import UIKit

internal final class SystemMessageTableViewCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet private weak var messageContainerView: UIView!

    @IBOutlet private weak var messageLabel: UILabel!


    // MARK: - Internal properties

    var cellViewModel: MessageChatCellViewModel?


    // MARK: - Internal functions

    func setup(cellViewModel: MessageChatCellViewModel) {
        self.cellViewModel = cellViewModel
        self.messageLabel.attributedText = cellViewModel.messageText.attributed()
    }
}
