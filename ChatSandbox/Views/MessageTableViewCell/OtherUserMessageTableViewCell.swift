//
//  OtherUserMessageTableViewCell.swift
//  ChatSandbox
//

import UIKit

internal final class OtherUserMessageTableViewCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet private weak var messageContainerView: UIView!

    @IBOutlet private weak var messageLabel: UILabel!

    @IBOutlet private weak var sentTimeLabel: UILabel!


    // MARK: - Internal properties

    var cellViewModel: MessageChatCellViewModel?


    // MARK: - Internal functions

    func setup(cellViewModel: MessageChatCellViewModel) {
        self.cellViewModel = cellViewModel
        self.messageLabel.attributedText = cellViewModel.messageText.attributed()
        self.sentTimeLabel.text = cellViewModel.sentAtText

        self.messageLabel.isUserInteractionEnabled = false
        self.messageLabel.alpha = 1.0

        for gestureRecognizer in self.messageLabel.gestureRecognizers ?? [] {
            self.messageLabel.removeGestureRecognizer(gestureRecognizer)
        }
    }
}
