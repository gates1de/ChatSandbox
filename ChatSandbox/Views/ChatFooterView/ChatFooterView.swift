//
//  ChatFooterView.swift
//  ChatSandbox
//

import UIKit

internal final class ChatFooterView: UIView {

    // MARK: - IBOutlets

    @IBOutlet weak var messageTextView: UITextView!

    @IBOutlet weak var messagePlaceholderLabel: UILabel!

    @IBOutlet weak var sendButton: UIButton!


    // MARK: - Static properties

    static let baseHeight: CGFloat = CGFloat(64.0)


    // MARK: - Internal properties

    var tapSendButtonHandler: (() -> (Void))?


    // MARK: - Lifecycles

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNib()
    }


    // MARK: - Internal functions

    func setup() {
        self.sendButton.addTarget(self, action: #selector(ChatFooterView.didTapSendButton(_:)), for: .touchUpInside)
    }


    // MARK: - Private functions

    private func loadNib() {
        let view = UINib(nibName: ChatFooterView.className, bundle: Bundle(for: type(of: self)))
            .instantiate(withOwner: self, options: nil)
            .first as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
        self.setup()
    }

    @objc private func didTapSendButton(_ sender: UIButton) {
        self.tapSendButtonHandler?()
    }
}
