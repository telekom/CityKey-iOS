//
//  SCDeleteAccountViewController+Displaying.swift
//  OSCA
//
//  Created by Bhaskar N S on 26/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension SCDeleteAccountViewController: SCDeleteAccountDisplaying {
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setupTitleLabel(with title: String) {
        self.titleLabel.text = title
    }

    func setupNavTitle(with title: String) {
        self.navigationItem.title = LocalizationKeys.DeleteAccount.d001DeleteAccountInfoTitle.localized()
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    func setupDescriptionLabel(with text: String) {
        self.descriptionLabel.text = text
    }
    
    func setupDeleteAccountButton(with title: String) {
        self.deleteAccountButton.setTitle(title, for: .normal)
        self.deleteAccountButton.customizeBlueStyle()
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
}
