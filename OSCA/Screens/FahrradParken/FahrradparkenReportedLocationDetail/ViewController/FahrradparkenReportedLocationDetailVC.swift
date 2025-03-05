/*
Created by Bhaskar N S on 22/05/23.
Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

class FahrradparkenReportedLocationDetailVC: UIViewController {
    
    @IBOutlet weak var mainCategotyLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var serviceRequestIdLabel: UILabel!
    @IBOutlet weak var serviceDescriptionLabel: UILabel!
    @IBOutlet weak var serviceStatusLabel: UILabel!
    @IBOutlet weak var serviceStatusView: UIView!
    @IBOutlet weak var detailIcon: UIImageView!
    @IBOutlet weak var mainCategoryView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var moreInformationBtnLabel: UILabel!
    
    
    var presenter: FahrradparkenReportedLocationDetailPresenting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccessibility()
        presenter.setDisplay(self)
        presenter.viewDidLoad()
    }
    
    @IBAction func moreInformationTapped(_ sender: Any) {
        if let urlStr = presenter.getMoreInformationUrl(),
           let url = URL(string: urlStr),
           UIApplication.shared.canOpenURL(url) {
            SCInternalBrowser.showURL(url, withBrowserType: .safari)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true) { [weak self] in
            self?.presenter.handleCompletion()
        }
    }
}
