//
//  String.swift
//  ChatSandbox
//

import Foundation
import UIKit

extension String {

    // MARK: - Internal functions

    func height(frameWidth width: CGFloat, font: UIFont, lineSpacing: CGFloat = 4.0) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = CGFloat(lineSpacing)

        let boundingBox = self.boundingRect(
            with       : constraintRect,
            options    : .usesLineFragmentOrigin,
            attributes : [.font: font, .paragraphStyle: paragraphStyle], context: nil
        )

        return ceil(boundingBox.height)
    }

    func attributed(font: UIFont = UIFont.systemFont(ofSize: 14),
                    lineBreakMode: NSLineBreakMode = .byWordWrapping) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self, attributes: [
            .font           : font,
            .baselineOffset : NSNumber(value: Float(1.0)) // g や q などが切れる対策
        ])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing   = CGFloat(4.0)
        paragraphStyle.lineBreakMode = lineBreakMode
        attributedString.addAttribute(
            .paragraphStyle,
            value:paragraphStyle,
            range: NSMakeRange(0, attributedString.length)
        )

        return attributedString
    }

}
