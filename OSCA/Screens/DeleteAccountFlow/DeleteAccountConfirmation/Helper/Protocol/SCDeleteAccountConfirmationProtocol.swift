/*
Created by Bhaskar N S on 26/06/22.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bhaskar N S
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCDeleteAccountConfirmationPresenting: SCPresenting {
    func setDisplay(_ display: SCDeleteAccountConfirmationDisplaying)
    func confirmButtonWasPressedWithPassword(password: String)
    func recoverPwdWasPressed()
    func passwordFieldDidBeginEditing()
    func showPasswordWasPressed()
    func passwordFieldHasText()
    func passwordFieldIsEmpty()
    func closeButtonWasPressed()
}

protocol SCDeleteAccountConfirmationDisplaying: AnyObject, SCDisplaying {
    func setupNavigationBar(title: String, backTitle: String)
    func setupRecoverLoginBtn(title: String)
    func setupPasswordField(title: String)
    func setupPasswordErrorLabel(title: String)
    func setupConfirmationButton(title: String)
    func setupTitleLabel(title: String)
    func hidePWDError()
    func showPasswordSelected(_ selected: Bool)
    func showTopLabel()
    func hideTopLabel()
    func showPasswordIncorrectLabel()
    func passwordTextfieldResignFirstResponder()
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)?)
    func popToRootViewController()
    func push(viewController: UIViewController)
    func setConfirmButtonState(_ state : SCCustomButtonState)
    func confirmButtonState() -> SCCustomButtonState
    func dismiss(completion: (() -> Void)?)
}

protocol SCDeleteAccountConfirmationWorking {
    func deleteAccount(_with password: String, completion: @escaping (SCWorkerError?) -> ())
}
