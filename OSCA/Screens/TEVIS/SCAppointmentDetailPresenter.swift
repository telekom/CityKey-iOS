//
//  SCAppointmentDetailPresenter.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 24/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import TTGSnackbar

class SCAppointmentDetailPresenter {

    private weak var display: SCAppointmentDetailDisplaying?

    private var appointment: SCModelAppointment
    private let injector: SCQRCodeInjecting & SCMapViewInjecting
    private let serviceData: SCBaseComponentItem
    private let appointmentWorker: SCAppointmentWorking
    private let cityID: Int
    
    private lazy var config: AppointmentViewConfigurable = {
        return appointment.apptStatus.getConfig(appointmentEndDate: appointment.endDate)
    }()

    private weak var appointmentDelegate: (SCAppointmentDeleting & SCAppointmentStatusChanging)?

    init(appointment: SCModelAppointment,
         appointmentWorker: SCAppointmentWorking,
         cityID: Int,
         injector: SCQRCodeInjecting & SCMapViewInjecting,
         serviceData: SCBaseComponentItem,
         appointmentDelegate: (SCAppointmentDeleting & SCAppointmentStatusChanging)?)
        {
        self.cityID = cityID
        self.appointment = appointment
        self.injector = injector
        self.appointmentWorker = appointmentWorker
        self.serviceData = serviceData
        self.appointmentDelegate = appointmentDelegate
    }

    private func setupMap() {
        let mapAddress = "\(appointment.street), \(appointment.place)"
        if mapAddress.count == 0 {
            display?.hideMap()
        } else {
            display?.showMap(latitude: 0.0, longitude: 0.0, locationName: "", locationAddress: mapAddress, markerTintColor: kColor_cityColor, mapInteractionEnabled: false, showDirectionsBtn: false)
        }
    }

    private func setupUI() {
        self.display?.displayCancelMeetingBtn(config.isCancelable)
        setupMap()
    }

    private func getAppointmentReasonFormattedText(reasonTitle: String = LocalizationKeys.SCAppointmentDetailPresenter.apnmt003ConcernsLabel.localized()) -> String? {
        let reason = appointment.reasons.map {
            return "\t\u{2022} \($0.sNumber) x \($0.description)"
        }.joined(separator: "\n")

        return reason != "" ? "\(reasonTitle)\n\(reason)" : nil
    }

    private func getAppointmentParticipantFormattedText() -> String? {
        let participantTitle = LocalizationKeys.SCAppointmentDetailPresenter.apnmt003ParticipantsLabel.localized()
        let participant = appointment.attendee.map {
            return "\t\u{2022} \($0.firstName) \($0.lastName)"
        }.joined(separator: "\n")

        return participant != "" ? "\(participantTitle)\n\(participant)" : nil
    }

    private func getCalendarNotesText() -> String {
        var noteText = [String]()
        let address = String(format: LocalizationKeys.SCAppointmentDetailPresenter.apnmt003CalExportLocationFormat.localized().replaceStringFormatter(), appointment.addressDesc)
        noteText.append(address)

        if let reasonText = getAppointmentReasonFormattedText() {
            noteText.append(reasonText)
        }

        if let participantText = getAppointmentParticipantFormattedText() {
            noteText.append(participantText)
        }

        return noteText.joined(separator: "\n")
    }

    private func getAppointmentShareableDate() -> String {
        if let startDate = appointment.startDate {
            return stringFromDate(date: startDate)
        }

        return ""
    }

    private func getAppointmentShareableTitle() -> String {
        let title = LocalizationKeys.SCAppointmentDetailPresenter.apnmt005ShareTitle.localized().replaceStringFormatter()
        return String(format: title, arguments: [appointment.title,
                                                 getAppointmentShareableDate(),
                                                 getAppointmentStartTime()])
        
    }

    private func getAppointmentShareableText() -> String {
        var shareableText = [String]()

        if let reasonText = getAppointmentReasonFormattedText(reasonTitle: LocalizationKeys.SCAppointmentDetailPresenter.apnmt005ShareConcerns.localized()) {
            shareableText.append(reasonText)
        }

        return shareableText.joined(separator: "\n")
    }

    private func getAppointmentShareableUrl() -> URL {
        let mapAddress = "\(appointment.street), \(appointment.place)"
        return GlobalConstants.appendURLPathToUrlString("https://maps.google.com/",
                                                           path: "",
                                                           parameter: ["q": mapAddress])
    }
}

extension SCAppointmentDetailPresenter: SCAppointmentDetailPresenting {

    func viewDidLoad() {
        setupUI()
    }

    func viewDidAppear() {}

    func viewWillAppear() {}

    func set(display: SCAppointmentDetailDisplaying) {
        self.display = display
    }

    func getAppointmentTitle() -> String {
        return appointment.title
    }

    func getServiceImage() -> SCImageURL? {
        return serviceData.itemImageURL
    }

    func getAppointmentSetDate() -> String {
        if let createdDate = appointment.createdDate {
            let date = stringFromDate(date: createdDate)
            let presentableDate = String(format: LocalizationKeys.SCAppointmentDetailPresenter.apnmt003AppointmentCreationFormat.localized().replaceStringFormatter(), date)
            return presentableDate
        }

        return ""
    }

    func getAppointmentStartTime() -> String {
        return appointment.startTime
    }

    func getAppointmentEndTime() -> String {
        return appointment.endTime
    }

    func getAppointmentReason() -> String {
        return appointment.reasons.map {
            return "› \($0.sNumber) x \($0.description)"
        }.joined(separator: "\n")
    }

    func getAppointmentWaitingNumber(waitingTitle: String) -> String? {
        guard let waitingNumber = appointment.waitingNumber, !waitingNumber.isEmpty else {
            return nil
        }

        return String(format: waitingTitle, waitingNumber)
    }

    func getAppointmentParticipant() -> String {
        return appointment.attendee.map {
            return "› \($0.firstName) \($0.lastName)"
        }.joined(separator: "\n")
    }

    func getAppointmentBringWith() -> String {
        return appointment.documents.map {
            return "› \($0)"
        }.joined(separator: "\n")
    }

    func getAppointmentAdditional() -> String {
        return appointment.notes
    }

    func getAppointmentContactDescription() -> String {
        var contactTextList = [String]()

        if appointment.contact.contactDesc != "" {
            contactTextList.append(appointment.contact.contactDesc)
        }

        if appointment.contact.email != "" {
            let emailPrefix = LocalizationKeys.SCAppointmentDetailPresenter.p001ProfileLabelEmail.localized()
            contactTextList.append("\(emailPrefix): \(appointment.contact.email)")
        }

        if appointment.contact.telephone != "" {
            let telefonePrefix = LocalizationKeys.SCAppointmentDetailPresenter.apnmt003ApnmtTelefonLabel.localized().replaceStringFormatter()
            contactTextList.append(String(format: telefonePrefix, appointment.contact.telephone))
        }

        if appointment.contact.contactNotes != "" {
            contactTextList.append(appointment.contact.contactNotes)
        }

        let contactText = contactTextList.map {
            return "› \($0)"
        }.joined(separator: "\n")

        return contactText
    }

    func getAppointmentDate() -> String? {
        if let startDate = appointment.startDate {
            let calendarDate = Calendar.current.dateComponents([.day], from: startDate)
            return String(calendarDate.day!)
        }
        return nil
    }

    func getAppointmentDayMonthPresentable() -> String? {
        if let startDate = appointment.startDate {
            return "\(getDayName(_for: startDate)), \(getMonthName(_for: startDate))"
        }
        return nil
    }

    func getAppointmentAddressPresentable() -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 14, weight: .bold)
        let addressAttributedText = NSMutableAttributedString(string: appointment.addressDesc, attributes: [NSAttributedString.Key.font : font])

        let streetPlaceText = "\n\(appointment.street)\n\(appointment.place)"
        let streetPlaceAttributedText = NSAttributedString(string: streetPlaceText)
        addressAttributedText.append(streetPlaceAttributedText)

        return addressAttributedText
    }

    func getQRCodeViewConfiguration() -> (isAvailable: Bool, alpha: CGFloat) {
        return (config.isQRCodeAvailable, config.isQRCodeAvailable ? 1.0 : 0.2)
    }

    func getAddToCalendarViewConfiguration() -> (isAvailable: Bool, alpha: CGFloat) {
        return (config.isAddToCalendarAvailable, config.isAddToCalendarAvailable ? 1.0 : 0.2)
    }

    func addAppointmentToCalendar() {
        guard let startDate = appointment.startDate,
            let endDate = appointment.endDate else {
                return
        }
        let location = "\(appointment.street), \(appointment.place)"

        SCCalendarHelper.shared.addEvent(title: appointment.title,
                                         url: getAppointmentShareableUrl().absoluteString,
                                         startDate: startDate,
                                         endDate: endDate,
                                         note: getCalendarNotesText(),
                                         location: location)
    }

    func displayQRCodeViewController() {
        let qrCodecontroller = injector.getQRCodeController(for: appointment)
        display?.present(viewController: qrCodecontroller)
    }

    func mapViewWasPressed(latitude: Double, longitude: Double, zoomFactor: Float, address: String) {
        let mapAddress = "\(appointment.street), \(appointment.place)"
        let mapNavigationController = injector.getMapController(latitude: 0.0,
                                                                longitude: 0.0,
                                                                zoomFactor: zoomFactor,
                                                                address: mapAddress,
                                                                locationName: appointment.place, tintColor: kColor_cityColor) as! UINavigationController
        let mapController = mapNavigationController.viewControllers.first as! SCMapViewController
        mapController.delegate = self
        mapController.title = appointment.title
        self.display?.present(viewController: mapNavigationController)
    }

    func directionsButtonWasPressed(latitude : Double, longitude : Double, address: String) {
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = address
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }

    func getRightBarButton() -> UIBarButtonItem? {
        if (appointment.endDate?.isHistoric() == true)
            || (appointment.apptStatus == .rejected)
            || (appointment.apptStatus == .cancellation) {
            return UIBarButtonItem(title: LocalizationKeys.SCAppointmentDetailPresenter.b002InfoboxSwipedBtnDelete.localized(), style: .plain, target: self, action: #selector(deleteAppointment))
        } else if appointment.apptStatus == .confirmed || appointment.apptStatus == .reservation {
            let shareButton = UIBarButtonItem(image: UIImage(named: "icon_share"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(share))
            shareButton.accessibilityTraits = .button
            shareButton.accessibilityLabel = LocalizationKeys.SCAppointmentDetailPresenter.accessibilityBtnShareContent.localized()
            shareButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
            return shareButton
        }

        return nil
    }

    @objc private func deleteAppointment() {
        appointmentDelegate?.deleteAppointmentOf(id: appointment.apptId)
        display?.popViewController()
    }

    @objc func share() {
        let sharableText: String = [getAppointmentShareableTitle(),
                                    getAppointmentShareableText(),
                                    getAppointmentWaitingNumber(waitingTitle: LocalizationKeys.SCAppointmentDetailPresenter.apnmt005ShareWaitingNoFormat.localized().replaceStringFormatter()) ?? "",
                                    LocalizationKeys.SCAppointmentDetailPresenter.apnmt005ShareAddress.localized()].joined(separator: "\n\n")

        let emailTitle = String(format: LocalizationKeys.SCAppointmentDetailPresenter.apnmt003ShareTextTitle.localized().replaceStringFormatter(),
                                appointment.title)

        var objectsToShare: [Any] = [sharableText, getAppointmentShareableUrl(),
                                     "\n\n", LocalizationKeys.SCAppointmentDetailPresenter.shareStoreHeader.localized(), "\n"]
        if let uuid = appointment.uuid,
            let qrCode = QRCodeGenerator.getQRCode(from: uuid) {
            objectsToShare.append(qrCode)
        }
        SCShareContent.share(objects: objectsToShare,
                             emailTitle: emailTitle,
                             sourceRect: nil)
    }

    func bottomBtnWasPressed() {
        
        
        if "NOT REQUIRED" == ( serviceData.itemServiceParams?["action_cancel"] ?? "" ) {
            
            self.display?.stopLoadingIndicator()
            display?.showAlert(title: LocalizationKeys.SCAppointmentDetailPresenter.apnmt003CancelAppointmentBtn.localized(), message: LocalizationKeys.SCAppointmentDetailPresenter.apnmt003CancelErrorApnmtInfo.localized() , OkButton: LocalizationKeys.SCAppointmentDetailPresenter.appointmentWebCancelDialogBtnCancel.localized())
            return
        }
                
        display?.showCancelMeetingAlert(with: {
                self.display?.stopLoadingIndicator()
        }, okCompletion: {
            if !SCUtilities.isInternetAvailable() {
                self.display?.stopLoadingIndicator()
                self.display?.showErrorDialog(.noInternet, retryHandler: nil)
                return
            }

            self.appointmentWorker.cancelAppointment(for: "\(self.cityID)",  uuid: self.appointment.uuid ?? "", completion: {
                [weak self] (error) in

                self?.display?.stopLoadingIndicator()
                
                if error != nil {
                    switch error {
                    case .noInternet:
                        self?.display?.showErrorDialog(error!, retryHandler: nil)
                        return
                    default:
                        break
                    }

                    let snackbar = TTGSnackbar(
                        message: LocalizationKeys.SCAppointmentDetailPresenter.apnmt003SnackbarCancelationFailed.localized(),
                        duration: .middle
                    )
                    snackbar.setCustomStyle()
                    snackbar.show()
                    return
                }

                self?.appointmentDelegate?.markAppointmentAsCanceled(id: self?.appointment.apptId ?? 0)
                self?.display?.popViewController()
            })
        })
    }
}

extension SCAppointmentDetailPresenter: SCMapViewDelegate {

    func mapWasTapped(latitude: Double, longitude: Double, zoomFactor: Float, address: String) {
        
    }

    func directionsBtnWasPressed(latitude: Double, longitude: Double, address: String) {
        directionsButtonWasPressed(latitude: latitude, longitude: longitude, address: address)
    }
}
