//
//  MessageCellViewModel.swift
//  ChatSandbox
//

import UIKit

internal final class MessageChatCellViewModel {

    // MARK: - Internal properties

    var chatMessage: ChatMessage

    var isSending: Bool = false

    /// 強制改行するまでの文字数
    var messageGroupCount: Int {
        guard let type = self.chatMessage.type else { return 16 }
        switch type {
        case .normal:
            return UIScreen.main.scale >= 3.0 ? 16 : 13
        case .system:
            return UIScreen.main.scale >= 3.0 ? 30 : 24
        }
    }

    var messageText: String {
        return self.chatMessage.message
    }

    var sentAtText: String {
        return self.chatMessage.sentAt?.dateValue().toString(with: .hourToMinute) ?? ""
    }

    var isRead: Bool {
        return self.chatMessage.isReadUserId.count != 0
    }

    var isSent: Bool? {
        return self.chatMessage.isSent
    }


    // MARK: - Initializers

    init(chatMessage: ChatMessage) {
        self.chatMessage = chatMessage
    }
}
