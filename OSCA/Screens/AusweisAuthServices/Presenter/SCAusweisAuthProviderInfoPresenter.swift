/*
Created by Bharat Jagtap on 16/03/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bharat Jagtap
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation
import UIKit

protocol SCAusweisAuthProviderInfoPresenting : SCPresenting {
    
    func setDisplay(display : SCAusweisAuthProviderInfoDisplay)
    func onProviderLinkClicked()
    func onIssuerLinkClicked()
}

class SCAusweisAuthProviderInfoPresenter {

    private weak var display : SCAusweisAuthProviderInfoDisplay!
    var worker : SCAusweisAuthWorking
    var injector : SCAusweisAuthServiceInjecting
    
    init(worker : SCAusweisAuthWorking, injector : SCAusweisAuthServiceInjecting) {
        self.worker = worker
        self.injector = injector
    }
    
    func viewDidLoad() {

        self.display.setProvider(self.worker.state.certificate?.subjectName ?? "")
        self.display.setProviderLink(self.worker.state.certificate?.subjectUrl ?? "")
        self.display.setIssuer(self.worker.state.certificate?.issuerName ?? "")
        self.display.setIssuerLink(self.worker.state.certificate?.issuerUrl ?? "")
        self.display.setProviderInfo(self.worker.state.certificate?.termsOfUsage ?? "")
        
        if let effectiveDate = self.worker.state.certificate?.effectiveDate , let expiryDate = self.worker.state.certificate?.expirationDate {
            self.display.setValidity("\(effectiveDate) - \(expiryDate)")
        } else {
            self.display.setValidity("")
        }
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
}

extension SCAusweisAuthProviderInfoPresenter : SCAusweisAuthProviderInfoPresenting {
    
    func setDisplay(display : SCAusweisAuthProviderInfoDisplay) {
        self.display = display
    }
    
    func onProviderLinkClicked() {
        
        if let link = URL(string:self.worker.state.certificate?.subjectUrl ?? "" ) {
            UIApplication.shared.open(link, options: [:] , completionHandler: nil)
        }
    }
    
    func onIssuerLinkClicked() {

        if let link = URL(string:self.worker.state.certificate?.issuerUrl ?? "" ) {
            UIApplication.shared.open(link, options: [:] , completionHandler: nil)
        }

    }
}
