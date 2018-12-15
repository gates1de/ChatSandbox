//
//  Room.swift
//  ChatSandbox
//

import CodableFirebase
import FirebaseFirestore

struct Room: ModelProtocol {

    // MARK: - Enums

    enum CodingKeys: String, CodingKey {
        case id
        case userIds
        case userNames
        case lastMessage
        case lastMessageUserName
        case iconURLString = "iconURL"
        case createdAt
        case updatedAt
    }


    // MARK: - Static properties

    static let collectionName: String = "rooms"


    // MARK: - Internal properties

    var id: String?

    var userIds: [String]

    var userNames: [String]

    var lastMessage: String

    var lastMessageUserName: String

    var iconURLString: String?

    var createdAt: Timestamp?

    var updatedAt: Timestamp?


    // MARK: - Initializers

    /// Initializer
    init(id: String?,
         userIds: [String],
         userNames: [String],
         lastMessage: String,
         lastMessageUserName: String,
         iconURLString: String?,
         createdAt: Timestamp,
         updatedAt: Timestamp) {
        self.id                  = id
        self.lastMessage         = lastMessage
        self.userIds             = userIds
        self.userNames           = userNames
        self.lastMessageUserName = lastMessageUserName
        self.iconURLString       = iconURLString
        self.createdAt           = createdAt
        self.updatedAt           = updatedAt
    }
}

extension Room {
    var iconURL: URL? {
        get {
            return URL(string: self.iconURLString ?? "")
        }
        set {
            self.iconURLString = newValue?.absoluteString ?? ""
        }
    }
}
