//
//  SCDeleteAccountErrorPresenting.swift
//  OSCA
//
//  Created by Bhaskar N S on 26/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCDeleteAccountErrorDisplaying {
    func setupTitleLabel(with title: String)
    func setupSubtitleLabel(with title: String)
    func setupOkButton(with title: String)
    func dismissDeleteAccountFlow()
    func dismiss(completion: (() -> Void)?)

}

protocol SCDeleteAccountErrorPresenting: AnyObject, SCPresenting {
    func setDisplay(_ display: SCDeleteAccountErrorDisplaying)
    func okButtonTapped()
    func closeButtonWasPressed()

}
