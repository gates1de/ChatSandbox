//
//  AlertBuilder.swift
//  ChatSandbox
//

import UIKit

internal final class AlertBuilder {

    // MARK: - Static functions

    static func normalAlert(title: String,
                            message: String,
                            isCancel: Bool = false,
                            okHandler: ((UIAlertAction) -> Void)? = nil,
                            cancelHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(
            title          : title,
            message        : message,
            preferredStyle : .alert
        )

        let okAction = UIAlertAction(title: "OK", style: .default, handler: okHandler)
        alertController.addAction(okAction)

        if isCancel {
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: cancelHandler)
            alertController.addAction(cancelAction)
        }

        return alertController
    }
}
