//
//  SCDeleteAccountSuccessPresenting.swift
//  OSCA
//
//  Created by Bhaskar N S on 26/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCDeleteAccountSuccessDisplaying {
    func setupTitleLabel(text: String)
    func setupSubtitleLabel(text: String)
    func setupDescriptionLabel(text: String)
    func setupNavigationBar(with title: String)
    func setupOkButton(with title: String)
    func dismissDeleteAccountFlow()
    func dismiss(completion: (() -> Void)?)

}

protocol SCDeleteAccountSuccessPresenting: AnyObject, SCPresenting {
    func setDisplay(_ display: SCDeleteAccountSuccessDisplaying)
    func okButtonTapped()
    func closeButtonWasPressed()
}
