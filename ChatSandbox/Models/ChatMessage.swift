//
//  ChatMessage.swift
//  ChatSandbox
//

import CodableFirebase
import FirebaseFirestore
import Foundation

struct ChatMessage: ModelProtocol {

    // MARK: - Enums

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case userName
        case typeRawValue
        case message
        case isReadUserId
        case isSent
        case sentAt
    }

    enum MessageType: String {
        case normal
        case system
    }

    // MARK: - Static properties

    static let collectionName: String = "chatMessages"


    // MARK: - Internal properties

    var id: String?

    var userId: String

    var userName: String

    var typeRawValue: String

    var message: String

    var isReadUserId: [String]

    var isSent: Bool?

    var sentAt: Timestamp?


    // MARK: - Initializers

    /// Initializer
    init(id: String?,
         userId: String,
         userName: String,
         type: MessageType,
         message: String,
         isReadUserId: [String] = [],
         isSent: Bool? = nil,
         sentAt: Timestamp) {
        self.id           = id
        self.userId       = userId
        self.userName     = userName
        self.typeRawValue = type.rawValue
        self.message      = message
        self.isReadUserId = isReadUserId
        self.isSent       = isSent
        self.sentAt       = sentAt
    }
}

extension ChatMessage {

    // MARK: - Computed properties

    var type: MessageType? {
        get {
            return MessageType(rawValue: self.typeRawValue)
        }
        set {
            self.typeRawValue = newValue?.rawValue ?? ""
        }
    }
}
