//
//  ChatTitleView.swift
//  ChatSandbox
//

import UIKit

internal final class ChatTitleView: UIView {

    // MARK: - IBOutlets

    @IBOutlet private weak var containerView: UIStackView!

    @IBOutlet private weak var userIconImageVIew: UIImageView!

    @IBOutlet private weak var userNameLabel: UILabel!


    // MARK: - UIView properties

    override var intrinsicContentSize: CGSize {
        return self.frame.size
    }


    // MARK: - Static functions

    static func generate(with userIconUrl: URL?, userName: String, superViewSize: CGSize) -> ChatTitleView {
        let nib = UINib(nibName: String(describing: ChatTitleView.self), bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! ChatTitleView
        view.setup(userIconUrl: userIconUrl, userName: userName, superViewSize: superViewSize)
        return view
    }


    // MARK: - Private functions

    private func setup(userIconUrl: URL?, userName: String, superViewSize: CGSize) {
        self.userNameLabel.text = userName
        self.userIconImageVIew.setImage(with: userIconUrl, placeholder: #imageLiteral(resourceName: "user-icon"))

        self.layoutIfNeeded()
        // userName が長すぎる場合は containerView の幅に制約をかける (閾値はいい感じの値)
        let thresholdWidth = superViewSize.width * 0.75
        if self.userNameLabel.frame.width > thresholdWidth {
            self.containerView.widthAnchor.constraint(equalToConstant: thresholdWidth).isActive = true
        }
    }
}
