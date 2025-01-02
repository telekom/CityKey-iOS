//
//  SCAppointmentOverviewPresenter.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 16/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import TTGSnackbar

protocol SCAppointmentOverviewPresenting: SCPresenting {
    func setupUI()
    func setDisplay(_ display: SCAppointmentOverviewDisplaying)
    func updateAppointments()
    func displayAppointmentDetails(appointment: SCModelAppointment)
    func displayQRCodeViewController(appointment: SCModelAppointment)
    func deleteAppointment(at index: Int)
    func deleteAppointmentOf(id: Int)
    func displayToastWith(message: String)
}

class SCAppointmentOverviewPresenter {

    weak private var display: SCAppointmentOverviewDisplaying?

    private let userCityContentSharedWorker: SCUserCityContentSharedWorking
    private let cityContentCityIdentifier: SCCityContentCityIdentifing
    private let appointmentWorker: SCAppointmentWorking

    private var appointmentList: [SCModelAppointment]
    private var injector: SCAppointmentInjecting & SCQRCodeInjecting & SCCitizenSurveyServiceInjecting & SCAdjustTrackingInjection
    private let serviceData: SCBaseComponentItem
    private weak var appointmentDeletor: SCAppointmentDeleting?
    
    private var appointDeletionInProgress = false

    init(userCityContentSharedWorker: SCUserCityContentSharedWorking,
         cityContentCityIdentifier: SCCityContentCityIdentifing,
         appointmentWorker: SCAppointmentWorking,
         injector: SCAppointmentInjecting & SCQRCodeInjecting & SCCitizenSurveyServiceInjecting & SCAdjustTrackingInjection,
         serviceData: SCBaseComponentItem,
         appointmentDeletor: SCAppointmentDeleting) {
        self.userCityContentSharedWorker = userCityContentSharedWorker
        self.cityContentCityIdentifier = cityContentCityIdentifier
        self.appointmentWorker = appointmentWorker
        self.injector = injector
        self.serviceData = serviceData
        self.appointmentDeletor = appointmentDeletor

        appointmentList = []
        setupNotifications()
    }

    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self,
                                             on: .didChangeAppointmentsDataState,
                                             with: #selector(updateAppointmentPresentation))
    }

    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }

    @objc private func updateAppointmentPresentation() {
        if !self.appointDeletionInProgress{
            hideAllErrorView()
            handleAppointmentPresentation()
        }
    }

    private func handleAppointmentSuccessPresentation() {
        if appointmentList.count == 0 {
            display?.displayNoAppointmentMessageView()
        } else {
            display?.hideNoAppointmentMessageView()
        }
    }

    private func handleAppointmenFailurePresentation() {
        if appointmentList.count == 0 {
            display?.displayErrorView()
        } else {
            display?.hideErrorView()
        }
        display?.show(appointments: appointmentList)
    }

    private func hideAllErrorView() {
        display?.hideErrorView()
        display?.hideNoAppointmentMessageView()
    }

    private func displayAppointments() {
        appointmentList = userCityContentSharedWorker.getAppointments().sorted {
            if let firstDate = $0.startDate, let secondDate = $1.startDate {
                return firstDate < secondDate
            } else {
                return false
            }
        }
        handleAppointmentSuccessPresentation()
        display?.show(appointments: appointmentList)
    }

    private func handleAppointmentPresentation() {
        let appointmentFetchState = userCityContentSharedWorker.appointmentsDataState.dataLoadingState

        switch appointmentFetchState {
        case .needsToBefetched:
            // show loading indicator and initiate fetch call
            display?.startRefreshing()
            updateAppointments()

        case .fetchingInProgress:
            // show loading indicator
            display?.startRefreshing()

        case .fetchFailed:
            // Show the failure error if appointments are empty else display locally persisted appointments.
            display?.endRefreshing()
            handleAppointmenFailurePresentation()

        case .fetchedWithSuccess:
            // Display appointment result
            display?.endRefreshing()
            displayAppointments()
            // mark also all as read when getting new data in the overview screen
            self.markAppointmentsAsRead()

        case .backendActionNotAvailableForCity:
            // Currently this scenario is not available
            break
        }
    }

    private func displaySuccessToast(appointmentId: Int) {
        let snackbar = TTGSnackbar(message: LocalizationKeys.SCAppointmentOverviewPresenter.apnmtSnackbarSuccessfullyDelete.localized(),
                                   duration: .middle,
                                   actionText: LocalizationKeys.SCAppointmentOverviewPresenter.b006SnackbarDeleteUndo.localized()) {
            [weak self] (snackbar) in
            
            guard let presenterSelf = self else {
                return
            }

            let cityId = presenterSelf.cityContentCityIdentifier.getCityID()
            presenterSelf.appointmentWorker.deleteAppointments(for: "\(cityId)", appointmentId: appointmentId, status: false, completion: { (error) in
                if error != nil {
                    presenterSelf.display?.showErrorDialog(error!, retryHandler: nil)
                } else {
                    presenterSelf.updateAppointments()
                }
            })
        }

        snackbar.setCustomStyle()
        snackbar.actionButton.accessibilityLabel = LocalizationKeys.SCAppointmentOverviewPresenter.b006SnackbarDeleteUndo.localized()
        snackbar.actionButton.accessibilityTraits = .button
        snackbar.actionButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        snackbar.show()
    }

    private func delete(appointment: SCModelAppointment) {
        self.appointDeletionInProgress = true
        let cityId = cityContentCityIdentifier.getCityID()
        appointmentWorker.deleteAppointments(for: "\(cityId)", appointmentId: appointment.apptId, status: true, completion: {
            [weak self] (error) in

            self?.appointDeletionInProgress = false

            if error != nil {
                switch error {
                case .noInternet:
                    self?.display?.showErrorDialog(error!, retryHandler: nil)
                    return

                default:
                    break
                }

                self?.displayToastWith(message: LocalizationKeys.SCAppointmentOverviewPresenter.apnmtDeleteErrorSnackbar.localized())
                // In case of failure, reset the appointment list
                self?.updateAppointments()
            } else {
                self?.displaySuccessToast(appointmentId: appointment.apptId)
            }
            
        })
    }
    
    func markAppointmentsAsRead() {
        let appointments = userCityContentSharedWorker.getAppointments()
        let unreadAppointments = appointments.filter { $0.isRead == false }
            
        let unreadApptIDs = unreadAppointments.map { $0.apptId }
        

        if unreadApptIDs.count > 0 {
            
            if !SCUtilities.isInternetAvailable() {
                self.display?.showErrorDialog(.noInternet, retryHandler: nil)
                return
            }

            self.userCityContentSharedWorker.markAppointmentsAsRead()

            let cityId = cityContentCityIdentifier.getCityID()
                appointmentWorker.markAppointmentsAsRead(for: "\(cityId)", appointmentIds: unreadApptIDs, completion: {
                [weak self] (error) in

                if error != nil {
                    switch error {
                    case .noInternet:
                        self?.display?.showErrorDialog(error!, retryHandler: nil)
                        return

                    default:
                        break
                    }

                    self?.displayToastWith(message: LocalizationKeys.SCAppointmentOverviewPresenter.apnmt003SnackbarMarkReadFailed.localized())
                    self?.updateAppointments()
                }
            })
        }
    }
}

extension SCAppointmentOverviewPresenter: SCAppointmentOverviewPresenting {

    func setupUI() {
        handleAppointmentPresentation()
    }

    func setDisplay(_ display: SCAppointmentOverviewDisplaying) {
        self.display = display
    }

    func updateAppointments() {
        userCityContentSharedWorker.triggerAppointmentsUpdate {
            [weak self] (error) in

            self?.display?.endRefreshing()

            switch error {
                case .noInternet:
                    DispatchQueue.main.async {
                        self?.display?.showNoInternetAvailableDialog(retryHandler: self?.updateAppointments,
                                                                     showCancelButton: true,
                                                                     additionalButtonTitle: nil,
                                                                     additionButtonHandler: nil)
                    }
                default: break
            }
        }
    }

    func displayAppointmentDetails(appointment: SCModelAppointment) {
        let cityId = self.cityContentCityIdentifier.getCityID()
        let appointmentDetailController = injector.getAppointmentDetailController(for: appointment,
                                                                                  cityID: cityId,
                                                                                  serviceData: serviceData, appointmentDelegate: self)
        display?.push(viewController: appointmentDetailController)
    }

    func displayQRCodeViewController(appointment: SCModelAppointment) {
        let qrCodecontroller = injector.getQRCodeController(for: appointment)
        display?.present(viewController: qrCodecontroller)
    }

    func deleteAppointment(at index: Int) {
        
        let deletedAppointment = appointmentList.remove(at: index)

        // Call delete API here
        delete(appointment: deletedAppointment)

        // Update UserCityContentSharedWorker appointment list
        userCityContentSharedWorker.update(appointments: appointmentList)

        handleAppointmentSuccessPresentation()

    }

    func displayToastWith(message: String) {
        let snackbar = TTGSnackbar(
            message: message,
            duration: .middle
        )

        snackbar.setCustomStyle()
        snackbar.show()
    }
}

extension SCAppointmentOverviewPresenter: SCAppointmentDeleting & SCAppointmentStatusChanging {

    func deleteAppointmentOf(id: Int) {
        guard let index = appointmentList.firstIndex(where: {$0.apptId == id}) else {
            return
        }

        deleteAppointment(at: index)
    }

    func markAppointmentAsCanceled(id: Int) {
        guard let index = appointmentList.firstIndex(where: {$0.apptId == id}) else {
            return
        }

        appointmentList[index].apptStatus = .cancellation
        userCityContentSharedWorker.update(appointments: appointmentList)
        display?.show(appointments: appointmentList)
    }
}

extension SCAppointmentOverviewPresenter: SCPresenting {
    func viewDidLoad() {
        self.setupUI()
        self.markAppointmentsAsRead()
    }
    
    func viewWillAppear() { }
    
    func viewDidAppear() { }
}

