/*
Created by Michael on 20.06.20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCCityImprintDisplaying: AnyObject, SCDisplaying {
    func setupUI()
    func updateCityName(_ cityName : String)
    func updateCityImage(withURL: SCImageURL?)
    func updateImprintDesc(_ imprintDesc : String?)
    func handleAppPreviewBannerView()
    func updateImprintImage(withUrl: SCImageURL?)
}

protocol SCCityImprintPresenting: SCPresenting {
    func setDisplay(_ display: SCCityImprintDisplaying)
        
    func locationButtonWasPressed()
    func profileButtonWasPressed()
    func imprintButtonWasPressed()
}

class SCCityImprintPresenter {

    weak private var display: SCCityImprintDisplaying?

    private let injector: SCToolsShowing
    private let cityContentSharedWorker: SCCityContentSharedWorking
    
    init(cityContentSharedWorker: SCCityContentSharedWorking, injector: SCToolsShowing) {

        self.cityContentSharedWorker = cityContentSharedWorker
        self.injector = injector
        self.setupNotifications()
    }

    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }

    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeLocation, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeCityContent, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .didUpdateAppPreviewMode, with: #selector(handleAppPreviewModeChange))
    }
    
    @objc private func handleAppPreviewModeChange() {
        self.display?.handleAppPreviewBannerView()
    }

    @objc private func didChangeContent() {
        self.refreshUIContent()
    }
    
    @objc private func didChangeLocation() {
         self.refreshUIContent()
    }

    private func refreshUIContent() {
        if let contentModel = self.cityContentSharedWorker.getCityContentData(for: self.cityContentSharedWorker.getCityID()) {
            self.display?.updateCityName(contentModel.city.name)
            display?.updateCityImage(withURL: contentModel.city.municipalCoatImageUrl)
            self.display?.updateImprintDesc(contentModel.cityImprintDesc)
            display?.updateImprintImage(withUrl: contentModel.imprintImageUrl)
        } else {
            display?.updateCityImage(withURL: nil)
            display?.updateImprintImage(withUrl: nil)
        }
    }
}

// MARK: - SCPresenting

extension SCCityImprintPresenter: SCPresenting {
    func viewDidLoad() {
        self.display?.setupUI()
        self.refreshUIContent()

    }
}

// MARK: - SCServicesPresenting

extension SCCityImprintPresenter: SCCityImprintPresenting {
    
    func setDisplay(_ display: SCCityImprintDisplaying) {
        self.display = display
    }

    func locationButtonWasPressed() {
        self.injector.showLocationSelector()
    }
     
    func profileButtonWasPressed() {
        self.injector.showProfile()
    }

    func imprintButtonWasPressed() {
        if let cityImprintLink = self.cityContentSharedWorker.getCityContentData(for: self.cityContentSharedWorker.getCityID())?.cityImprint,
            let urlToOpen = URL(string: cityImprintLink),
            UIApplication.shared.canOpenURL(urlToOpen) {
                SCInternalBrowser.showURL(urlToOpen, withBrowserType: .safari)
        }
    }

    
}
