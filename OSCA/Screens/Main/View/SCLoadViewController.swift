/*
Created by Michael on 07.12.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import Lottie

class SCLoadViewController: UIViewController {

    @IBOutlet weak var launchImage: UIImageView!
    @IBOutlet weak var oscaImageView: UIImageView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    var loadCompletionHandler: (() -> Void)?
    var refreshHandler : SCSharedWorkerRefreshHandling?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
        createAndPlayLoadingAnimation()
    }
    
    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .launchScreenNoInternet, with: #selector(noInternetOnLaunchScreen))
        SCDataUIEvents.registerNotifications(for: self, on: .launchScreenRetry, with: #selector(handleRetryOnNoInterenete))
    }
    
    @objc private func noInternetOnLaunchScreen() {
        self.launchImage.isHidden = false
        self.loadingView.isHidden = true
    }
    
    @objc private func handleRetryOnNoInterenete() {
        refreshHandler?.reloadContent(force: true)
        self.launchImage.isHidden = true
        self.loadingView.isHidden = false
        
    }
    
    func createAndPlayLoadingAnimation() {
        loadingView.animation = LottieAnimation.named(animationAssestForLoader())
        loadingView.play(fromFrame: 0, toFrame: 29) { isFinished in
            self.loadingView.play(fromFrame: 30, toFrame: 59, loopMode: .loop) { _ in
            }
        }
    }
    
    func finishLoading() {
        self.loadingView.loopMode = .playOnce
        loadingView.play(fromFrame: 60, toFrame: 69) { isFinished in
            self.loadCompletionHandler?()
        }
    }
    
    private func animationAssestForLoader() -> String {
        switch traitCollection.userInterfaceStyle {
        case .unspecified,
                .light:
            return "CityKey_Splashlogo_lightmode"
        case .dark:
            return "CityKey_Splashlogo_darkmode"
        @unknown default:
            return "CityKey_Splashlogo_lightmode"
        }
    }
}
