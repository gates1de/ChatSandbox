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
        case lastMessage
        case lastMessageUserName
        case createdAt
        case updatedAt
    }


    // MARK: - Static properties

    static let collectionName: String = "rooms"


    // MARK: - Internal properties

    var id: String?

    var userIds: [String]

    var lastMessage: String

    var lastMessageUserName: String

    var createdAt: Timestamp?

    var updatedAt: Timestamp?


    // MARK: - Initializers

    /// Initializer
    init(id: String?,
         userIds: [String],
         lastMessage: String,
         lastMessageUserName: String,
         createdAt: Timestamp,
         updatedAt: Timestamp) {
        self.id                  = id
        self.lastMessage         = lastMessage
        self.userIds             = userIds
        self.lastMessageUserName = lastMessageUserName
        self.createdAt           = createdAt
        self.updatedAt           = updatedAt
    }
}
