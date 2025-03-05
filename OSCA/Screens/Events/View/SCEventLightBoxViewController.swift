/*
Created by Alexander Lichius on 05.12.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Alexander Lichius
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCEventLightBoxDisplaying: AnyObject, SCDisplaying {
    func setupImage(_with imageUrl: SCImageURL)
    func setupCreditLabel(_with text: String)
    func dismiss()
}

protocol SCEventLightBoxDismissDelegate {
    func dismissBlurView()
}

class SCEventLightBoxViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var creditLabel: UILabel!
    var presenter: SCEventLightBoxPresenting!
    var dismissDelegate: SCEventLightBoxDismissDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.definesPresentationContext = true
        //self.modalPresentationStyle = .currentContext
        self.presenter.setDisplay(display: self)
        self.presenter.viewDidLoad()
        self.view.bringSubviewToFront(self.closeButton)
        self.view.bringSubviewToFront(self.creditLabel)
        
    }

    @IBAction func closeButtonWasTapped(_ sender: Any) {
        self.dismissDelegate.dismissBlurView()
        self.presenter.closeButtonWasTapped()
    }
}

extension SCEventLightBoxViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

extension SCEventLightBoxViewController: SCEventLightBoxDisplaying {
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupImage(_with imageUrl: SCImageURL) {
        self.imageView.load(from: imageUrl, maxWidth: self.view.frame.width)
    }
    
    func setupCreditLabel(_with text: String) {
        self.creditLabel.text = text
    }
}
