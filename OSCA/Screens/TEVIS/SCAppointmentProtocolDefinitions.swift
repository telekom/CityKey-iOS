//
//  SCAppointmentProtocolDefinitions.swift
//  OSCA
//
//  Created by Michael on 01.11.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCAppointmentDeleting: AnyObject {
    func deleteAppointmentOf(id: Int)
}

protocol SCAppointmentStatusChanging: AnyObject {
    func markAppointmentAsCanceled(id: Int)
}

protocol SCAppointmentDetailPresenting: SCPresenting {
    func set(display: SCAppointmentDetailDisplaying)
    func getAppointmentTitle() -> String
    func getServiceImage() -> SCImageURL?
    func getAppointmentSetDate() -> String
    func getAppointmentStartTime() -> String
    func getAppointmentEndTime() -> String
    func getAppointmentReason() -> String
    func getAppointmentWaitingNumber(waitingTitle: String) -> String?
    func getAppointmentParticipant() -> String
    func getAppointmentBringWith() -> String
    func getAppointmentAdditional() -> String
    func getAppointmentContactDescription() -> String
    func getAppointmentDate() -> String?
    func getAppointmentDayMonthPresentable() -> String?
    func getAppointmentAddressPresentable() -> NSAttributedString
    func getQRCodeViewConfiguration() -> (isAvailable: Bool, alpha: CGFloat)
    func getAddToCalendarViewConfiguration() -> (isAvailable: Bool, alpha: CGFloat)
    func addAppointmentToCalendar()
    func displayQRCodeViewController()
    func mapViewWasPressed(latitude: Double, longitude: Double, zoomFactor: Float, address: String)
    func directionsButtonWasPressed(latitude : Double, longitude : Double, address: String)
    func share()
    func bottomBtnWasPressed()
    func getRightBarButton() -> UIBarButtonItem?
}
