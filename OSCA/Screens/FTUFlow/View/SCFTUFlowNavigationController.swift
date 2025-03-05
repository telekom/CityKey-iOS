/*
Created by Michael on 25.01.20.
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

class SCFTUFlowNavigationController: UINavigationController {

    public var presenter: SCFTUFlowPresenting!
    private var firstTimeViewController : SCFirstTimeUsageVC?
    private var launchScreenView : UIView?
    override func viewWillAppear(_ animated: Bool) {
        self.setNavigationBarHidden(true, animated: false)
        self.shouldNavBarTransparent = true
        self.refreshNavigationBarStyle()

        self.presenter.viewWillAppear()
        SCUtilities.lockOrientation(.portrait, andRotateTo: .portrait)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SCUtilities.lockOrientation(.all)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.presenter.viewDidAppear()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let ftVC = self.viewControllers.first as? SCFirstTimeUsageVC else {
            fatalError("SCFirstTimeUsageVC is expected")
        }
        
        self.firstTimeViewController = ftVC

        self.firstTimeViewController?.addScreen(with: "FTU-screen1", description: LocalizationKeys.SCFTUFlowNavigationController.x001WelcomeInfo01.localized(), header: LocalizationKeys.SCFTUFlowNavigationController.x001welcomeInfoTitle01.localized(), screenNo: 0)
        self.firstTimeViewController?.addScreen(with: "FTU-screen2", description: LocalizationKeys.SCFTUFlowNavigationController.x001WelcomeInfo02.localized(), header: LocalizationKeys.SCFTUFlowNavigationController.x001welcomeInfoTitle02.localized(), screenNo: 1)
        self.firstTimeViewController?.addScreen(with: "FTU-screen3", description: LocalizationKeys.SCFTUFlowNavigationController.x001WelcomeInfo03.localized(), header: LocalizationKeys.SCFTUFlowNavigationController.x001welcomeInfoTitle03.localized(), screenNo: 2)
        self.firstTimeViewController?.addScreen(with: "FTU-screen4", description: LocalizationKeys.SCFTUFlowNavigationController.x003WelcomeInfo.localized(), header: LocalizationKeys.SCFTUFlowNavigationController.x003WelcomeInfoTitle.localized(), screenNo: 3)
        self.firstTimeViewController?.setUpControlsVisibility(true, isPageControlAvailable: true)

        self.firstTimeViewController?.delegate = self

        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()

    }
    
}

// MARK: - SCFTUFlowDisplaying
extension SCFTUFlowNavigationController: SCFTUFlowDisplaying {
    
    func push(viewController: UIViewController) {
        self.pushViewController(viewController, animated: true)
    }

    func present(viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func showActivityView(){
        if self.launchScreenView == nil {
            self.launchScreenView = UIStoryboard(name: "LoadScreen", bundle: nil).instantiateInitialViewController()!.view!
            self.launchScreenView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.launchScreenView!.frame = self.firstTimeViewController!.view.bounds

            self.firstTimeViewController!.view.addSubview(launchScreenView!)
        }
    }

    func hideActivityView(){
        self.launchScreenView?.removeFromSuperview()
        self.launchScreenView = nil
    }

    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }

}

// MARK: - SCFirstTimeUsageVCDelegate
extension SCFTUFlowNavigationController: SCFirstTimeUsageVCDelegate {
    
    func loginBtnWasPressed() {
        self.presenter.loginBtnWasPressed()
    }
    
    func registerBtnWasPressed() {
        self.presenter.registerBtnWasPressed()
    }

    func skipButtonWasPressed(){
        self.presenter.skipButtonWasPressed()
    }
    
}
