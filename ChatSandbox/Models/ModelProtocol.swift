//
//  ModelProtocol.swift
//  ChatSandbox
//

import CodableFirebase
import FirebaseFirestore

extension Timestamp: TimestampType {}

internal protocol ModelProtocol: Codable {
    var id: String? { get set }

    func toDictionary(isWithoutId: Bool) -> [String: Any]?
}

extension ModelProtocol {

    static func initialize(id: String, json: [String: Any]) -> Self? {
        do {
            var model = try FirestoreDecoder().decode(self, from: json)
            model.id = id
            return model
        } catch {
            print(error)
            return nil
        }
    }

    func toDictionary(isWithoutId: Bool = false) -> [String: Any]? {
        do {
            var dictionary = try FirestoreEncoder().encode(self)
            if isWithoutId {
                dictionary.removeValue(forKey: "id")
            }
            return dictionary
        } catch {
            print(error)
            return nil
        }
    }
}
