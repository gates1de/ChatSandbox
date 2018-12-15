//
//  MyMessageTableViewCell.swift
//  ChatSandbox
//

import UIKit

internal final class MyMessageTableViewCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet private weak var messageContainerView: UIView!

    @IBOutlet private weak var messageLabel: UILabel!

    @IBOutlet private weak var sendingIndicatorView: UIActivityIndicatorView!

    @IBOutlet private weak var nextActionButton: UIButton!

    @IBOutlet private weak var isReadLabel: UILabel!

    @IBOutlet private weak var sentTimeLabel: UILabel!


    // MARK: - Internal properties

    var cellViewModel: MessageChatCellViewModel?

    var sendFailureHandler: ((ChatMessage) -> Void)?


    // MARK: - Internal functions

    func setup(cellViewModel: MessageChatCellViewModel, sendFailureHandler: @escaping ((ChatMessage) -> Void)) {
        self.cellViewModel               = cellViewModel
        self.sendFailureHandler          = sendFailureHandler
        self.messageLabel.attributedText = cellViewModel.messageText.attributed()
        self.sentTimeLabel.text          = cellViewModel.sentAtText
        self.isReadLabel.isHidden        = !cellViewModel.isRead
        self.nextActionButton.isHidden   = cellViewModel.isSent != false
        self.nextActionButton.addTarget(self, action: #selector(MyMessageTableViewCell.didTapNextActionButton(_:)), for: .touchUpInside)
        // メッセージ送信中は, nextActionButton を常に非表示にする
        if cellViewModel.isSending == true {
            self.nextActionButton.isHidden = true
        }

        self.messageLabel.isUserInteractionEnabled = false
        self.messageLabel.alpha = 1.0

        for gestureRecognizer in self.messageLabel.gestureRecognizers ?? [] {
            self.messageLabel.removeGestureRecognizer(gestureRecognizer)
        }

        // 未送信扱いのデータは送信中かどうか, インジケータの表示判定をおこなう
        if self.cellViewModel?.isSending  == true {
            self.sendingIndicatorView.startAnimating()
        } else {
            self.sendingIndicatorView.stopAnimating()
        }
    }


    // MARK: - Private functions

    @objc private func didTapNextActionButton(_ sender: UIButton) {
        guard let cellViewModel = self.cellViewModel else { return }
        self.sendFailureHandler?(cellViewModel.chatMessage)
    }
}
