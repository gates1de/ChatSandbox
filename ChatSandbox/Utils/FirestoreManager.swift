//
//  FirestoreManager.swift
//  ChatSandbox
//

import FirebaseFirestore

internal struct FirestoreManager {

    // MARK: - Static properties

    static let shared = FirestoreManager()


    // MARK: - Private properties

    var db: Firestore {
        let settings = Firestore.firestore().settings
        settings.areTimestampsInSnapshotsEnabled = true
        let firestore = Firestore.firestore()
        firestore.settings = settings
        return firestore
    }


    // MARK: - Initializers

    private init() { }
}
