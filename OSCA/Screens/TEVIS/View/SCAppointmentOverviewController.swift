//
//  SCAppointmentOverviewController.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 16/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCAppointmentOverviewDisplaying: AnyObject, SCDisplaying {
    func show(appointments: [SCModelAppointment])
    func startRefreshing()
    func endRefreshing()
    func displayErrorView()
    func hideErrorView()
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func displayNoAppointmentMessageView()
    func hideNoAppointmentMessageView()
}

class SCAppointmentOverviewController: UIViewController {

    @IBOutlet weak var appointmentTableView: UITableView!

    private lazy var footerView: RetryView? = {
        let view = RetryView.getView()
        view?.errorTitleLabel.text = LocalizationKeys.SCAppointmentOverviewController.apnmt002ErrorInfo.localized()
        view?.errorDescriptionLabel.text = LocalizationKeys.SCAppointmentOverviewController.apnmt002ErrorDescription.localized()
        view?.retryButton.setTitle(LocalizationKeys.SCAppointmentOverviewController.b005InfoboxErrorBtnReload.localized(), for: .normal)
        view?.retryButton.setTitleColor(kColor_cityColor, for: .normal)
        view?.retryButton.titleLabel?.adaptFontSize()
        view?.retryButton.setImage(UIImage(named: "action_resend_email")?.maskWithColor(color: kColor_cityColor), for: .normal)
        view?.retryButton.addTarget(self, action: #selector(didTapOnRetry), for: .touchUpInside)
        return view
    }()

    private lazy var emptyMessageView: SCNoAppointmentMessageView? = {
        let view = SCNoAppointmentMessageView.getView()
        view?.noAppointmentLabel.text = LocalizationKeys.SCAppointmentOverviewController.apnmt002EmptyStateLabel.localized()
        view?.noAppointmentLabel.adaptFontSize()
        return view
    }()

    private var dataSource: SCAppointmentOverviewDataSource!
    private let refreshControl = UIRefreshControl()

    var presenter: SCAppointmentOverviewPresenting!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        presenter.setDisplay(self)
        presenter.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Responsible to set the height for tableviewHeader
        if let headerView = appointmentTableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame

            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                appointmentTableView.tableHeaderView = headerView
            }
        }
    }

    private func setupUI() {
        title = LocalizationKeys.SCAppointmentOverviewController.apnmt002PageTitle.localized()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: LocalizationKeys.Common.navigationBarBack.localized(),
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)

        registerCell()
        appointmentTableView.estimatedRowHeight = 60
        appointmentTableView.rowHeight = UITableView.automaticDimension
        setRefreshControl()
    }

    private func registerCell() {
        let cellName = String(describing: SCAppointmentOverviewTableViewCell.self)
        let cellNib = UINib(nibName: cellName, bundle: nil)
        appointmentTableView.register(cellNib, forCellReuseIdentifier: cellName)
    }

    private func setRefreshControl() {
        appointmentTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(updateAppointmentList), for: .valueChanged)
    }

    private func setDataSource(appointments: [SCModelAppointment]) {
        dataSource = SCAppointmentOverviewDataSource(appointments: appointments,
                                                     delegate: self)
        appointmentTableView.dataSource = dataSource
        appointmentTableView.delegate = dataSource
        appointmentTableView.reloadData()
    }

    @objc func updateAppointmentList() {
        presenter.updateAppointments()
    }

    @objc func didTapOnRetry() {
        presenter.updateAppointments()
        handleOnRetryErrorViewPresentation()
    }

    private func handleOnRetryErrorViewPresentation() {
        footerView?.activityIndicator.startAnimating()
        footerView?.errorDescriptionLabel.isHidden = true
        footerView?.errorTitleLabel.isHidden = true
        footerView?.retryButton.isHidden = true
    }
}

extension SCAppointmentOverviewController: SCAppointmentOverviewDisplaying {

    func show(appointments: [SCModelAppointment]) {
        setDataSource(appointments: appointments)
    }

    func startRefreshing() {
        refreshControl.beginRefreshing()
    }

    func endRefreshing() {
        refreshControl.endRefreshing()
    }

    func displayErrorView() {
        footerView?.activityIndicator.stopAnimating()
        footerView?.errorDescriptionLabel.isHidden = false
        footerView?.errorTitleLabel.isHidden = false
        footerView?.retryButton.isHidden = false
        appointmentTableView.tableFooterView = footerView
    }

    func hideErrorView() {
        appointmentTableView.tableFooterView = nil
    }

    func displayNoAppointmentMessageView() {
        appointmentTableView.tableHeaderView = emptyMessageView
    }

    func hideNoAppointmentMessageView() {
        appointmentTableView.tableHeaderView = nil
    }

    func push(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    func present(viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}

extension SCAppointmentOverviewController: SCAppointmentOverviewDelegate {

    func didSelected(appointment: SCModelAppointment) {
        presenter.displayAppointmentDetails(appointment: appointment)
    }

    func didTapOnQRCode(appointment: SCModelAppointment) {
        presenter.displayQRCodeViewController(appointment: appointment)
    }
}

extension SCAppointmentOverviewController: SCAppointmentOverviewDataSourceDelegate {

    func deleteAppointment(at index: Int) {
        presenter?.deleteAppointment(at: index)
    }

    func showToasteWith(message: String) {
        presenter?.displayToastWith(message: message)
    }
}

extension SCAppointmentOverviewController: SCAppointmentDeleting {

    func deleteAppointmentOf(id: Int) {
        presenter?.deleteAppointmentOf(id: id)
    }
}
