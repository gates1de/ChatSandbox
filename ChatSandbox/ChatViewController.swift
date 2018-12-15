//
//  ViewController.swift
//  ChatSandbox
//

import UIKit

internal final class ChatViewController: UIViewController {

    // MARK: - IBOutlet

    @IBOutlet private weak var messageTableView: UITableView! {
        didSet {
            self.messageTableView.dataSource = self
            self.messageTableView.delegate   = self

            let dateHeaderViewXib = UINib(nibName: ChatDateHeaderView.className, bundle: nil)
            self.messageTableView.register(
                dateHeaderViewXib,
                forHeaderFooterViewReuseIdentifier: ChatDateHeaderView.className
            )
        }
    }

    @IBOutlet private weak var footerView: ChatFooterView!

    @IBOutlet private weak var footerViewBottomConstraint: NSLayoutConstraint!

    @IBOutlet private weak var footerViewHeightConstraint: NSLayoutConstraint!


    // MARK: - Private properties

    private let roomId = "room1"

    private var viewModel = ChatViewModel()

    private var keyboardAnimationDuration = Double(0.35)

    private var isFirstLayout = false


    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.isFirstLayout {
            self.isFirstLayout = true

            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }


    // MARK: - Private functions

    private func setup() {
        let tableViewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.didTapTableView(_:)))
        tableViewTapGesture.cancelsTouchesInView = false
        self.messageTableView.addGestureRecognizer(tableViewTapGesture)
        self.footerView.messageTextView.delegate = self

        // メッセージの更新があったときの処理
        self.viewModel.updateMessageCompletion = { [weak self] (newMessageCellViewModelList, changedMessageCellViewModelList) in
            guard let `self` = self else { return }

            // 新規メッセージの追加
            for newMessageCellViewModel in newMessageCellViewModelList {
                self.viewModel.insertMessageChatCellViewModel(targetCellViewModel: newMessageCellViewModel)
                self.insertMessage(message: newMessageCellViewModel.chatMessage)
            }

            // メッセージの変更 (既に viewModel.dailyCellViewModelList は更新済みで, ここでは cell を更新するのみ)
            var reloadTargetRows: [IndexPath] = []
            for changedMessageCellViewModel in changedMessageCellViewModelList {
                if let targetIndexPath = self.viewModel.indexPath(for: changedMessageCellViewModel.chatMessage) {
                    reloadTargetRows.append(targetIndexPath)
                }
            }

            if !reloadTargetRows.isEmpty {
                // 自動スクロールを止めてしまう可能性があるので 0.3秒後 に更新
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.messageTableView.reloadRows(at: reloadTargetRows, with: .none)
                }
            }
        }

        self.viewModel.setup(roomId: self.roomId) { error in
            guard error == nil else {
                let alert = AlertBuilder.normalAlert(title: "データ取得失敗", message: "チャットデータの取得に失敗しました。")
                self.present(alert, animated: true)
                return
            }
            self.setupTitleView()

            self.footerView.tapSendButtonHandler = { [weak self] in
                guard let `self` = self else { return }
                guard let text = self.footerView.messageTextView.text, !text.isEmpty else { return }
                self.footerView.messageTextView.text = ""
                self.footerView.sendButton.isEnabled = false
                self.footerView.messagePlaceholderLabel.isHidden = false
                self.view.endEditing(true)
                self.viewModel.sendMessage(text: text)
            }

            self.reloadAndScrollToBottom()

            // chatMessages の変更監視開始
            self.viewModel.subscribeMessage()
        }
    }

    private func setupTitleView() {
        guard let room = self.viewModel.room else { return }
        let titleView = ChatTitleView.generate(
            with          : room.iconURL,
            userName      : room.userNames.filter({ $0 != self.viewModel.myUserName }).joined(separator: ", "),
            superViewSize : self.view.bounds.size
        )
        self.navigationItem.titleView = titleView
    }

    private func insertMessage(message: ChatMessage) {
        guard let targetIndexPath = self.viewModel.indexPath(for: message) else { return }

        self.messageTableView.beginUpdates()
        if targetIndexPath.row == 0 {
            self.messageTableView.insertSections([targetIndexPath.section], with: .fade)
        }
        self.messageTableView.insertRows(at: [targetIndexPath], with: .fade)
        self.messageTableView.endUpdates()

        // 最後に一番下にスクロール
        self.messageTableView.scrollToBottom(animated: false)
    }

    private func reloadAndScrollToBottom() {
        self.messageTableView.reloadData()
        self.messageTableView.scrollToBottom()
    }

    @objc private func didTapTableView(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @objc private func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
            return
        }
        // keyboard が閉じたと判定したときはレイアウトを変えない
        let keyboardHideThreshold = CGFloat(100.0)
        if keyboardHeight > keyboardHideThreshold {
            self.footerViewBottomConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
            return
        }

        self.footerViewBottomConstraint.constant = keyboardHeight
        UIView.animate(withDuration: self.keyboardAnimationDuration, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.messageTableView.scrollToBottom()
        })
    }

    @objc private func keyboardWillHide(_ notification: NSNotification) {
        self.footerViewBottomConstraint.constant = CGFloat(0.0)
        UIView.animate(withDuration: self.keyboardAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
}


extension ChatViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.dailyCellViewModelList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortedDateString = Array(viewModel.dailyCellViewModelList.keys).sorted(by: <)
        let dateString = sortedDateString[section]

        return viewModel.dailyCellViewModelList[dateString]?.count ?? 0
    }
}


extension ChatViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ChatDateHeaderView.baseHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ChatDateHeaderView.className) as? ChatDateHeaderView else {
            return nil
        }

        let sortedDateString = Array(viewModel.dailyCellViewModelList.keys).sorted(by: <)
        let dateString = sortedDateString[section]

        headerView.setup(dateString: dateString)
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let emptyCell = self.emptyCell(tableView, cellForRowAt: indexPath)
        let sortedDateString = Array(viewModel.dailyCellViewModelList.keys).sorted(by: <)
        let dateString = sortedDateString[indexPath.section]

        guard let dateCellViewModelList = viewModel.dailyCellViewModelList[dateString] else { return emptyCell }

        let cellViewModel = dateCellViewModelList[indexPath.row]
        let chatMessage   = cellViewModel.chatMessage

        guard let type = chatMessage.type else { return emptyCell }

        switch type {
        case .normal:
            if chatMessage.userId == self.viewModel.myUserId {
                return self.myMessageCell(tableView, cellForRowAt: indexPath, cellViewModel: cellViewModel)
            } else {
                return self.otherUserMessageCell(tableView, cellForRowAt: indexPath, cellViewModel: cellViewModel)
            }
        case .system:
            return self.systemMessageCell(tableView, cellForRowAt: indexPath, cellViewModel: cellViewModel)
        }
    }


    private func emptyCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: MyMessageTableViewCell.className, for: indexPath)
    }

    private func myMessageCell(_ tableView: UITableView,
                               cellForRowAt indexPath: IndexPath,
                               cellViewModel: MessageChatCellViewModel) -> MyMessageTableViewCell {
        let cellIdentifier = MyMessageTableViewCell.className
        let cell = tableView.dequeueReusableCell(withIdentifier : cellIdentifier, for: indexPath) as! MyMessageTableViewCell
        cell.setup(cellViewModel: cellViewModel) { [weak self] chatMessage in
            // 送信に失敗した場合のアクション( info ボタンのタップで呼び出される)
            self?.showNextActionAlert(message: chatMessage)
        }

        return cell
    }

    private func otherUserMessageCell(_ tableView: UITableView,
                                      cellForRowAt indexPath: IndexPath,
                                      cellViewModel: MessageChatCellViewModel) -> OtherUserMessageTableViewCell {
        let cellIdentifier = OtherUserMessageTableViewCell.className
        let cell = tableView.dequeueReusableCell(withIdentifier : cellIdentifier, for: indexPath) as! OtherUserMessageTableViewCell
        cell.setup(cellViewModel: cellViewModel)
        return cell
    }

    private func systemMessageCell(_ tableView: UITableView,
                                   cellForRowAt indexPath: IndexPath,
                                   cellViewModel: MessageChatCellViewModel) -> SystemMessageTableViewCell {
        let cellIdentifier = SystemMessageTableViewCell.className
        let cell           = tableView.dequeueReusableCell(withIdentifier : cellIdentifier, for: indexPath) as! SystemMessageTableViewCell
        cell.setup(cellViewModel: cellViewModel)
        return cell
    }

    private func showNextActionAlert(message: ChatMessage) {
        let alert = AlertBuilder.normalAlert(
            title   : "メッセージの送信失敗",
            message : "このメッセージは通信環境のよい場所で自動的に送信されます。"
        )

        self.present(alert, animated: true)
    }
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        self.footerView.sendButton.isEnabled             = !text.isEmpty
        self.footerView.messagePlaceholderLabel.isHidden = !text.isEmpty

        let frameWidth  = textView.frame.width - CGFloat(16.0)
        let font        = textView.font!
        let lineSpacing = CGFloat(8.0)
        let textHeight = text.height(frameWidth: frameWidth, font: font, lineSpacing: lineSpacing)
        let maxHeight = min(ChatFooterView.baseHeight + textHeight, CGFloat(140.0))
        self.footerViewHeightConstraint.constant = maxHeight

        self.footerView.messageTextView.isScrollEnabled = maxHeight >= CGFloat(140.0)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.footerViewBottomConstraint.constant = CGFloat(0.0)
    }
}
