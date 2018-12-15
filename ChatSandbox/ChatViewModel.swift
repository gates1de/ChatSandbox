//
//  ChatViewModel.swift
//  ChatSandbox
//

import FirebaseFirestore

internal struct EmptyError: Error { }

internal final class ChatViewModel {

    // MARK: - Internal properties

    let myUserId = "user1"

    let myUserName = "山田太郎"

    var room: Room?

    var isFirstSubscribe: Bool = true

    var allMessageList: [ChatMessage] = []

    var dailyCellViewModelList: [String: [MessageChatCellViewModel]] = [:]

    var messageCollectionRef: CollectionReference? {
        guard let roomId = self.room?.id else { return nil }
        return FirestoreManager.shared.db
            .collection(Room.collectionName)
            .document(roomId)
            .collection(ChatMessage.collectionName)
    }

    /// メッセージが追加 or 更新された時に呼び出すコールバック (第一引数: 新規メッセージの cellViewModel 配列, 第二引数: 変更メッセージの cellViewModel 配列)
    var updateMessageCompletion: (([MessageChatCellViewModel], [MessageChatCellViewModel]) -> Void)? = nil


    // MARK: - Initializers

    init() { }


    // MARK: - Internal functions

    func setup(roomId: String, completion: @escaping ((Error?) -> Void)) {
        FirestoreManager.shared.db
            .collection(Room.collectionName)
            .document(roomId)
            .getDocument() { snapshot, error in
                guard error == nil else {
                    completion(error!)
                    return
                }
                guard let snapshot = snapshot,
                      let roomData = snapshot.data(),
                      let room = Room.initialize(id: snapshot.documentID, json: roomData) else {
                    completion(EmptyError())
                    return
                }
                self.room = room
                self.fetchMessage(completion: completion)
            }
    }

    func subscribeMessage() {
        guard let messageCollectionRef = self.messageCollectionRef else {
            return
        }
        messageCollectionRef.addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
            guard error == nil else {
                print("get new message error: \(error!)")
                return
            }

            guard let snapshot = snapshot else {
                print("listener: snapshot is empty!")
                return
            }

            // 初回は全データの取得のためスルー
            if self.isFirstSubscribe {
                self.isFirstSubscribe = false
                return
            }

            var newMessageCellViewModelList     : [MessageChatCellViewModel] = []
            var changedMessageCellViewModelList : [MessageChatCellViewModel] = []
            var unreadPartnerMessageList        : [ChatMessage] = []
            var notSendMessageList              : [String: Bool?] = [:]

            // 新規メッセージの取得
            for document in snapshot.documents {
                let messageId  = document.documentID
                guard var newMessage = ChatMessage.initialize(id: messageId, json: document.data()) else {
                    continue
                }

                // まだ送信済みになっていないメッセージの場合
                if newMessage.isSent == nil || newMessage.isSent != true {
                    // キャッシュから取得したデータではない(リモートから取得した)と判断できる場合は, 送信済みとする(それ以外は送信失敗とみなす)
                    newMessage.isSent = !document.metadata.hasPendingWrites
                    notSendMessageList.updateValue(newMessage.isSent, forKey: messageId)
                }

                // それ以外の既に追加済みのメッセージはスルー
                guard !self.allMessageList.contains(where: { $0.id == messageId }) else {
                    continue
                }

                // messageId が, 自分の userId が含まれたシステムメッセージなら無視(表示しないメッセージのため)
                if newMessage.userId == self.myUserId && newMessage.type == .system {
                    self.allMessageList.append(newMessage)
                    continue
                }

                // 相手からの未読メッセージを受信したら既読したことにする (下の resetUnreadCount で Firestore 更新)
                if newMessage.userId != self.myUserId && !newMessage.isReadUserId.contains(self.myUserId) {
                    newMessage.isReadUserId.append(self.myUserId)
                    unreadPartnerMessageList.append(newMessage)
                }

                // ローカルに保持している room も新しいデータとして更新(同期)する
                self.room?.lastMessage = newMessage.message
                self.room?.updatedAt   = newMessage.sentAt

                let newMessageCellViewModel = MessageChatCellViewModel(chatMessage: newMessage)
                newMessageCellViewModelList.append(newMessageCellViewModel)
                self.allMessageList.append(newMessage)
            }

            // このブロックの中で未読メッセージがあった場合(つまりリアルタイムで新規メッセージを受け取った場合), 未読は常にリセットする
            if !snapshot.documents.isEmpty {
                self.resetUnreadCount(targetMessageList: unreadPartnerMessageList)
            }

            // 更新されたデータがあるかどうかのフラグ
            var isExistChangedData = false
            // 変更メッセージの取得
            for documentChange in snapshot.documentChanges {
                let messageId = documentChange.document.documentID
                guard var changedMessage = ChatMessage.initialize(id: messageId, json: documentChange.document.data()),
                      let sentAtString = changedMessage.sentAtString else {
                    continue
                }

                guard var dateCellViewModelList = self.dailyCellViewModelList[sentAtString],
                    let index = dateCellViewModelList.index(where: { $0.chatMessage.id == messageId }) else {
                    continue
                }

                let oldCellViewModel = dateCellViewModelList[index]
                let oldMessage       = oldCellViewModel.chatMessage


                // 既に取得してあるメッセージと差分がある場合, 保持しておく
                if oldMessage.isDiff(chatMessage: changedMessage) {
                    isExistChangedData = true
                }

                // messageId が, 自分の userId が含まれたシステムメッセージなら無視(表示しないメッセージのため)
                if changedMessage.userId == self.myUserId && changedMessage.type == .system {
                    if let index = self.allMessageList.index(where: { $0.id == changedMessage.id }) {
                        self.allMessageList[index] = changedMessage
                    }
                    continue
                }

                let changedCellViewModel = MessageChatCellViewModel(chatMessage: changedMessage)

                // isSending だけは ChatMessage に入っていないので, 前の値を引き継ぐ
                changedCellViewModel.isSending = oldCellViewModel.isSending

                // 変更があった場合のみ, dailyCellViewModelList を更新して, 下の updateMessageCompletion (VC内処理)で更新する
                if isExistChangedData {
                    dateCellViewModelList[index] = changedCellViewModel

                    if let sentAtString = changedMessage.sentAtString {
                        self.dailyCellViewModelList[sentAtString]?[index] = changedCellViewModel
                        changedMessageCellViewModelList.append(changedCellViewModel)
                    }
                }

                if let index = self.allMessageList.index(where: { $0.id == changedMessage.id }) {
                    self.allMessageList[index] = changedMessage
                }
            }

            self.updateMessageIsSent(targetList: notSendMessageList)
            self.updateMessageCompletion?(newMessageCellViewModelList, changedMessageCellViewModelList)
        }
    }

    func sendMessage(text: String, chatMessageType: ChatMessage.MessageType = .normal) {
        guard let messageCollectionRef = self.messageCollectionRef else {
            return
        }

        let chatMessage = self.generateChatMessage(text: text, chatMessageType: chatMessageType)

        guard let messageData = chatMessage.toDictionary() else {
            return
        }

        let cellViewModel = MessageChatCellViewModel(chatMessage: chatMessage)
        cellViewModel.isSending = true
        self.updateMessageCompletion?([cellViewModel], [])
        self.allMessageList.append(chatMessage)

        // ローカルの room も更新
        self.room?.lastMessage = chatMessage.message
        self.room?.updatedAt   = chatMessage.sentAt

        guard let roomData = self.room?.toDictionary() else {
            return
        }

        let batch = FirestoreManager.shared.db.batch()
        batch.setData(messageData, forDocument: messageCollectionRef.document(chatMessage.id ?? ""))
        batch.updateData(
            roomData,
            forDocument: FirestoreManager.shared.db
                .collection(Room.collectionName)
                .document(self.room?.id ?? "")
        )

        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "sendMessage")
        var errorResult: Error? = EmptyError()

        queue.async { [weak self] in
            batch.commit() { error in
                errorResult = error
                semaphore.signal()
            }

            let result = semaphore.wait(timeout: .now() + 10)
            self?.updateMessageSendResult(
                message   : chatMessage,
                isSending : false,
                isSent    : errorResult == nil && result == .success
            )
        }
    }

    func insertMessageChatCellViewModel(targetCellViewModel: MessageChatCellViewModel) {
        let chatMessage = targetCellViewModel.chatMessage
        guard let sentAtString = chatMessage.sentAtString else { return }

        if var dateCellViewModelList = self.dailyCellViewModelList[sentAtString] {
            dateCellViewModelList.append(targetCellViewModel)
            let sortedList = dateCellViewModelList.sorted(by: {
                ($0.chatMessage.sentAt?.seconds ?? 0) < ($1.chatMessage.sentAt?.seconds ?? 0)
            })
            self.dailyCellViewModelList.updateValue(sortedList, forKey: sentAtString)
        } else {
            self.dailyCellViewModelList.updateValue([targetCellViewModel], forKey: sentAtString)
        }
    }

    func sendSystemMessage() {
        let systemMessage = self.generateSystemMessage()
        guard let messageData = systemMessage.toDictionary() else { return }

        self.messageCollectionRef?.addDocument(data: messageData)
    }

    func indexPath(for message: ChatMessage) -> IndexPath? {
        var targetSection: Int?
        var targetRow    : Int?

        let sortedDateString = Array(self.dailyCellViewModelList.keys).sorted(by: <)

        for (index, dateString) in sortedDateString.enumerated() {
            if message.sentAtString == dateString {
                targetSection = index

                guard let dateCellViewModelList = self.dailyCellViewModelList[dateString] else { return nil }
                if let row = dateCellViewModelList.index(where: { $0.chatMessage.id == message.id }) {
                    targetRow = row
                } else {
                    targetRow = dateCellViewModelList.count
                }

                guard let section = targetSection, let row = targetRow else { return nil }
                return IndexPath(row: row, section: section)
            }
        }

        return nil
    }

    /// 未読メッセージを既読にする処理
    ///
    /// - Parameter targetMessageList: 更新対象のメッセージ配列
    func resetUnreadCount(targetMessageList: [ChatMessage]) {
        guard let messageCollectionRef = self.messageCollectionRef,
              !targetMessageList.isEmpty else {
            return
        }

        let batch = FirestoreManager.shared.db.batch()

        for message in targetMessageList {
            guard let messageId = message.id else { continue }
            batch.updateData(
                [ ChatMessage.CodingKeys.isReadUserId.rawValue: FieldValue.arrayUnion([self.myUserId]) ],
                forDocument: messageCollectionRef.document(messageId)
            )
        }

        batch.commit { error in
            if let error = error { print(error) }
        }
    }

    /// メッセージを日毎に分割する処理
    func createDailyCellViewModelList(chatMessageList: [ChatMessage]) -> [String: [MessageChatCellViewModel]] {
        var result: [String: [MessageChatCellViewModel]] = [:]

        for chatMessage in chatMessageList {
            let cellViewModel = MessageChatCellViewModel(chatMessage: chatMessage)
            guard let sentAtString = chatMessage.sentAtString else { continue }

            if var dateCellViewModelList = result[sentAtString] {
                dateCellViewModelList.append(cellViewModel)
                let sortedList = dateCellViewModelList.sorted(by: {
                    ($0.chatMessage.sentAt?.seconds ?? 0) < ($1.chatMessage.sentAt?.seconds ?? 0)
                })
                result.updateValue(sortedList, forKey: sentAtString)
            } else {
                result.updateValue([cellViewModel], forKey: sentAtString)
            }
        }

        return result
    }

    // MARK: - Private functions

    private func fetchMessage(completion: @escaping ((Error?) -> Void)) {
        guard let messageCollectionRef = self.messageCollectionRef else {
            completion(EmptyError())
            return
        }

        messageCollectionRef.getDocuments() { querySnapshot, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let querySnapshot = querySnapshot else {
                completion(EmptyError())
                return
            }

            var updatedChatMessageList: [ChatMessage] = []
            var unreadMessageList: [ChatMessage] = []

            for documentSnapshot in querySnapshot.documents {
                let messageId   = documentSnapshot.documentID
                let messageData = documentSnapshot.data()
                guard var chatMessage = ChatMessage.initialize(id: messageId, json: messageData) else {
                    continue
                }
                // messageId が, 自分の userId が含まれたシステムメッセージなら無視(表示しないメッセージのため)
                if chatMessage.userId == self.myUserId && chatMessage.type == .system {
                    self.allMessageList.append(chatMessage)
                    continue
                }

                // 相手からの未読メッセージを受信したら既読したことにする
                if chatMessage.userId != self.myUserId && !chatMessage.isReadUserId.contains(self.myUserId) {
                    chatMessage.isReadUserId.append(self.myUserId)
                    unreadMessageList.append(chatMessage)
                }

                updatedChatMessageList.append(chatMessage)

                // 重複チェック
                if !self.allMessageList.contains(where: { $0.id == chatMessage.id }) {
                    self.allMessageList.append(chatMessage)
                }
            }

            self.dailyCellViewModelList = self.createDailyCellViewModelList(chatMessageList: updatedChatMessageList)
            self.resetUnreadCount(targetMessageList: unreadMessageList)
            completion(nil)
        }
    }

    /// メッセージが Firestore (リモート) に届いたかそうでないかを更新する処理
    private func updateMessageIsSent(targetList: [String: Bool?]) {
        guard let messageCollectionRef = self.messageCollectionRef,
              !targetList.isEmpty else {
            return
        }

        let batch = FirestoreManager.shared.db.batch()

        for (messageId, isSent) in targetList {
            guard let isSent = isSent else { continue }
            batch.updateData(
                [ ChatMessage.CodingKeys.isSent.rawValue: isSent ],
                forDocument: messageCollectionRef.document(messageId)
            )
        }

        batch.commit() { error in
            if let error = error { print(error) }
        }
    }

    /// メッセージの送信中ステータスを更新 & 送信結果を更新する処理
    private func updateMessageSendResult(message: ChatMessage, isSending: Bool, isSent: Bool) {
        guard let messageId = message.id,
              let sentAtString = message.sentAtString,
              let dateCellViewModelList = self.dailyCellViewModelList[sentAtString],
              let index = dateCellViewModelList.index(where: { $0.chatMessage.id == messageId }) else {
                return
        }

        dateCellViewModelList[index].isSending = isSending
        dateCellViewModelList[index].chatMessage.isSent = isSent
        self.updateMessageIsSent(targetList: [ messageId: isSent ])
        self.dailyCellViewModelList[sentAtString] = dateCellViewModelList
        self.updateMessageCompletion?([], [dateCellViewModelList[index]])
    }

    private func generateChatMessage(text: String, chatMessageType: ChatMessage.MessageType = .normal) -> ChatMessage {
        return ChatMessage(
            id       : UUID().uuidString,
            userId   : self.myUserId,
            userName : self.myUserName,
            type     : chatMessageType,
            message  : text,
            sentAt   : Timestamp(date: Date())
        )
    }

    private func generateSystemMessage() -> ChatMessage {
        return ChatMessage(
            id       : UUID().uuidString,
            userId   : self.myUserId,
            userName : self.myUserName,
            type     : .system,
            message  : "これはシステムメッセージです",
            sentAt   : Timestamp(date: Date())
        )
    }
}
