//
//  SCCitizenSurveyOverviewViewController.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 09/12/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
