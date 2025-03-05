/*
Created by Rutvik Kanbargi on 09/12/20.
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

protocol SCCitizenSurveyOverviewDisplaying: AnyObject, SCDisplaying {
    func push(viewController: UIViewController)
    func displayNoSurveyEmptyView()
    func updateDataSource()
    func endRefreshing()
}

protocol SCCitizenSurveyOverviewDelegate: AnyObject {
    func selected(survey: SCModelCitizenSurveyOverview)
}

class SCCitizenSurveyOverviewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView(frame: CGRect.zero)
        }
    }

    private lazy var emptyView: SCNoAppointmentMessageView? = {
        let view = SCNoAppointmentMessageView.getView()
        view?.noAppointmentLabel.text = isPreviewMode ? LocalizationKeys.SCCitizenSurveyOverviewViewController.cs002PreviewErrorNoSurveys.localized() :  LocalizationKeys.SCCitizenSurveyOverviewViewController.cs002ErrorNoSurveys.localized()
        view?.noAppointmentLabel.textColor = UIColor.labelTextBlackCLR
        view?.noAppointmentLabel.adaptFontSize()
        return view
    }()

    private let refreshControl = UIRefreshControl()

    var presenter: SCCitizenSurveyOverviewPresenting?
    private var dataSource: SCCitizenSurveyOverviewTableViewDataSource?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Responsible to set the height for tableviewHeader
        if let headerView = tableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame

            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        self.presenter?.viewDidLoad()
    }

    private func setup() {
        self.title = LocalizationKeys.SCCitizenSurveyOverviewViewController.cs002PageTitle.localized()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: LocalizationKeys.Common.navigationBarBack.localized(),
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        SCDataUIEvents.registerNotifications(for: self,
                                             on: UIContentSizeCategory.didChangeNotification,
                                             with: #selector(handleDynamicType))
        presenter?.set(display: self)
        registerCell()
        setDataSource()
        setRefreshControl()
    }
    
    @objc private func handleDynamicType() {
        tableView.reloadData()
    }

    private func registerCell() {
        let cellId = String(describing: SCCitizenSurveyOverviewTableViewCell.self)
        let nib = UINib(nibName: cellId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }

    private func setDataSource() {
        dataSource = SCCitizenSurveyOverviewTableViewDataSource(surveyList: presenter?.getSurveyList() ?? [], delegate: self)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.reloadData()
        tableView.estimatedRowHeight = 105
        tableView.rowHeight = UITableView.automaticDimension
    }

    private func setRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshSurveyList), for: .valueChanged)
    }
    
    @objc private func refreshSurveyList() {
        presenter?.fetchSurveyList()
    }

    func updateSurveyList() {
        presenter?.fetchSurveyList()
    }
}

extension SCCitizenSurveyOverviewController: SCCitizenSurveyOverviewDisplaying {

    func push(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    func updateDataSource() {
        dataSource?.updateDataSource(with: presenter?.getSurveyList() ?? [])
        tableView.reloadData()
    }

    func endRefreshing() {
        refreshControl.endRefreshing()
    }
}

extension SCCitizenSurveyOverviewController: SCCitizenSurveyOverviewDelegate {

    func selected(survey: SCModelCitizenSurveyOverview) {
        presenter?.displaySurveyDetails(survey: survey)
    }

    func displayNoSurveyEmptyView() {
        tableView.tableHeaderView = emptyView
    }
}
