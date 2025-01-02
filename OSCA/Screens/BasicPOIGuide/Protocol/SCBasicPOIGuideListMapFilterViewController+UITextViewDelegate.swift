//
//  SCBasicPOIGuideListMapFilterViewController+UITextViewDelegate.swift
//  OSCA
//
//  Created by A106551118 on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit


extension SCBasicPOIGuideListMapFilterViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if UIApplication.shared.canOpenURL(URL) {
            SCInternalBrowser.showURL(URL, withBrowserType: .safari, title: title)
            return false
        }
        return true
    }
}
