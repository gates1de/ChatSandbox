//
//  UIImageView.swift
//  ChatSandbox
//

//import Nuke
import UIKit

extension UIImageView {

    // MARK: - Internal functions

    func setImage(with imageUrl: URL?, placeholder: UIImage? = nil) {
        guard let imageUrl = imageUrl else { return }

//        let options = ImageLoadingOptions(
//            placeholder: placeholder,
//            transition: .fadeIn(duration: 0.3)
//        )
//
//        Nuke.loadImage(with: imageUrl, options: options, into: self)
    }
}
