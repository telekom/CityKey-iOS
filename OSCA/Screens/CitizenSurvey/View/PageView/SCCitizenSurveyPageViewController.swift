/*
Created by Rutvik Kanbargi on 26/11/20.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Rutvik Kanbargi
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCCitizenSurveyViewControllerDisplaying: AnyObject, SCDisplaying {
    func previousPage(index: Int)
    func nextPage(index: Int)
    func popViewController()
    func popToSurveyListViewController()
    func present(viewController: UIViewController)
}

class SCCitizenSurveyPageViewController: UIViewController {

    @IBOutlet weak var pageContainerView: UIView!
    @IBOutlet weak var progressView: UIProgressView!

    var pageViewController: UIPageViewController!
    var presenter: SCCitizenSurveyPageViewPresenting?

    private var questionViewControllerList = [SCCitizenSurveyQuestionViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPageView()
        presenter?.setDisplay(display: self)
        self.title = LocalizationKeys.SCCitizenSurveyPageViewController.cs003PageTitle.localized()
        setNavBarButtons()
        progressView.transform = CGAffineTransform(scaleX: 1, y: 4)
        progressView.progressTintColor = kColor_cityColor

        guard let questionViewControllerList = presenter?.getSurveyQuestionControllerList() else {
            return
        }
        self.questionViewControllerList = questionViewControllerList
        pageViewController.setViewControllers([questionViewControllerList[0]], direction: .forward, animated: true, completion: nil)
        let initialProgress =  1.0 / Float(questionViewControllerList.count)
        progressView.setProgress(initialProgress, animated: true)
        setupAccessibilityIDs()
        setupAccessibility()
    }
    
    private func setupAccessibilityIDs(){
        progressView.accessibilityIdentifier = "progress_view"
    }
    
    private func setupAccessibility() {
        progressView.isAccessibilityElement = true
        progressView.accessibilityLabel = surveyStatus(currentIndex: 1)
        progressView.accessibilityValue = ""
        progressView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    private func surveyStatus(currentIndex: Int) -> String {
        let statusString = "accessiblity_progress_status".localized().replaceStringFormatter()
        return String(format: statusString, arguments: ["\(currentIndex)", "\(questionViewControllerList.count)"])
        
    }

    private func setupPageView() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        addChild(pageViewController)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.pageContainerView.addSubview(pageViewController.view)
        pageViewController.view.leadingAnchor.constraint(equalTo: self.pageContainerView.leadingAnchor).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: self.pageContainerView.trailingAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: self.pageContainerView.topAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: self.pageContainerView.bottomAnchor).isActive = true
        
        pageViewController.didMove(toParent: self)
    }

    private func setNavBarButtons() {
        navigationItem.hidesBackButton = true
        let backbutton = UIButton(type: .system)
        backbutton.setTitle(LocalizationKeys.Common.navigationBarBack.localized(), for: .normal)
        backbutton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        backbutton.setImage(UIImage(named: "icon_nav_back"), for: .normal)
        backbutton.imageEdgeInsets = UIEdgeInsets(top: 2, left: -8, bottom: 0, right: 0)
        backbutton.addTarget(self, action: #selector(displayAlert), for: .touchUpInside)
        let backBarButton = UIBarButtonItem(customView: backbutton)
        navigationItem.leftBarButtonItem = backBarButton
    }

    @objc private func displayAlert() {
        let alertController = UIAlertController(title: "", message: LocalizationKeys.SCCitizenSurveyPageViewController.cs004BackButtonDialog.localized(), preferredStyle: .alert)
        let noAction = UIAlertAction(title: LocalizationKeys.SCCitizenSurveyPageViewController.negativeButtonDialog.localized(), style: .default, handler: nil)
        let yesAction = UIAlertAction(title: LocalizationKeys.SCCitizenSurveyPageViewController.positiveButtonDialog.localized(), style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension SCCitizenSurveyPageViewController: SCCitizenSurveyViewControllerDisplaying {

    func previousPage(index: Int) {
        if index > 0 {
            pageViewController.setViewControllers([questionViewControllerList[index - 1]],
                                                  direction: .reverse, animated: true, completion: {_ in
            })

            let progress =  Float(index) / Float(questionViewControllerList.count)
            progressView.setProgress(progress, animated: true)
            accessibilityFocusOnTapOfNextOrPreviousBtn(index: index)
            progressView.accessibilityLabel = surveyStatus(currentIndex: (index))
        }
    }

    func nextPage(index: Int) {
        if index < questionViewControllerList.count - 1 {
            pageViewController.setViewControllers([questionViewControllerList[index + 1]],
                                                  direction: .forward, animated: true, completion: {_ in
            })

            let progress =  Float(index + 2) / Float(questionViewControllerList.count)
            progressView.setProgress(progress, animated: true)
            progressView.accessibilityLabel = surveyStatus(currentIndex: (index + 2))
            accessibilityFocusOnTapOfNextOrPreviousBtn(index: index + 1)
        } else {
            self.view.endEditing(false)
            presenter?.submitSurvey()
        }
    }

    func popViewController() {
        navigationController?.popViewController(animated: true)
    }

    func popToSurveyListViewController() {
        for viewController in navigationController?.viewControllers ?? [] {
            if let surveyOverviewController = viewController as? SCCitizenSurveyOverviewController {
                surveyOverviewController.updateSurveyList()
                navigationController?.popToViewController(surveyOverviewController, animated: true)
                break
            }
        }
    }

    func present(viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    private func accessibilityFocusOnTapOfNextOrPreviousBtn(index: Int) {
        UIAccessibility.post(notification: .layoutChanged, argument: progressView)
    }
}
