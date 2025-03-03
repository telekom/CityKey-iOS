/*
Created by Harshada Deshmukh on 02/05/22.
Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

/// Label that allows selection with long-press gesture, e.g. for copy-paste.
class SCCopyableLabel: UILabel {
    
    // MARK: - Setup
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextSelection()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextSelection()
    }
    
    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupTextSelection() {
        layer.addSublayer(selectionOverlay)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        addGestureRecognizer(longPress)
        isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(didHideMenu), name: UIMenuController.didHideMenuNotification, object: nil)
    }
    
    private let selectionOverlay: CALayer = {
        let layer = CALayer()
        layer.cornerRadius = 8
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.14).cgColor
        layer.isHidden = true
        return layer
    }()
    
    // MARK: - Showing and hiding the menu
    
    private func cancelSelection() {
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
    }
    
    @objc private func didHideMenu(_ notification: Notification) {
        selectionOverlay.isHidden = true
    }
    
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let text = text, !text.isEmpty else { return }
        becomeFirstResponder()
        
        let menu = menuForSelection()
        if !menu.isMenuVisible {
            selectionOverlay.isHidden = false
            menu.setTargetRect(textRect(), in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    private func textRect() -> CGRect {
        let inset: CGFloat = -4
        return textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines).insetBy(dx: inset, dy: inset)
    }
    
    private func menuForSelection() -> UIMenuController {
        let menu = UIMenuController.shared
        menu.menuItems = [
            UIMenuItem(title: "Copy", action: #selector(copyText)),
        ]
        return menu
    }
    
    // MARK: - Menu item actions
    
    @objc private func copyText(_ sender: Any?) {
        cancelSelection()
        let board = UIPasteboard.general
        board.string = text
    }
    
    // MARK: - UIView overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectionOverlay.frame = textRect()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        cancelSelection()
        return super.resignFirstResponder()
    }
}
