//
//  SCFTUFlowNavigationController.swift
//  SmartCity
//
//  Created by Michael on 25.01.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
