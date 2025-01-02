//
//  SCModelAppointment.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 16/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

struct SCHttpModelAppointmentReason: Codable {
    let sNumber: String?
    let description: String?
}

struct SCHttpModelAppointmentContact: Codable {
    let email: String?
    let contactDesc: String?
    let telefon: String?
    let contactNotes: String?
}

struct SCHttpModelAppointmentAttendee: Codable {
    let firstName: String?
    let lastName: String?
}

struct SCHttpModelAppointmentLocation: Codable {
    let addressDesc: String?
    let street: String?
    let houseNumber: String?
    let postalCode: String?
    let place: String?
}

struct SCHttpModelAppointment: Codable {
    let apptId: Int?
    let title: String?
    let apptStatus: String?
    let uuid: String?
    let waitingNo: String?
    let isRead: Bool
    let startTime: String?
    let endTime: String?
    let createdTime: String?
    let notes: String?
    let reasons: [SCHttpModelAppointmentReason]?
    let documents: [String]?
    let contacts: SCHttpModelAppointmentContact?
    let attendee: [SCHttpModelAppointmentAttendee]?
    let location: SCHttpModelAppointmentLocation?

    func toModel() -> SCModelAppointment {
        let status = AppointmentStatus(rawValue: apptStatus?.lowercased() ?? "") ?? .none
        let street = "\(location?.street ?? "") \(location?.houseNumber ?? "")"
        let place = "\(location?.postalCode ?? "") \(location?.place ?? "")"

        var date = ""
        if let startDate = startTime,
            let presentableDate = appointmentDate(from: startDate) {
            date = "\(presentableDate.day), \(presentableDate.date)"
        }

        var meetingStartTime = ""
        if let startDate = startTime,
            let time = appointmentTime(from: startDate) {
            meetingStartTime = time
        }

        var meetingEndTime = ""
        if let endDate = endTime,
            let time = appointmentTime(from: endDate) {
            meetingEndTime = time
        }

        let presentableTime = "\(meetingStartTime) - \(meetingEndTime)"

        let createdDate = createdTime != nil ? dateFromString(dateString: createdTime!) : nil
        let startDate = startTime != nil ? dateFromString(dateString: startTime!) : nil
        let endDate = endTime != nil ? dateFromString(dateString: endTime!) : nil

        return SCModelAppointment(apptId: apptId ?? -1,
                                  title: title ?? "",
                                  apptStatus: status,
                                  addressDesc: location?.addressDesc ?? "",
                                  street: street,
                                  place: place,
                                  date: date,
                                  time: presentableTime,
                                  createdDate: createdDate,
                                  startDate: startDate,
                                  endDate: endDate,
                                  startTime: meetingStartTime,
                                  endTime: meetingEndTime,
                                  reasons: getReason(),
                                  attendee: getAttendee(),
                                  contact: SCModelAppointmentContact(contactDesc: contacts?.contactDesc ?? "",
                                                                     telephone: contacts?.telefon ?? "",
                                                                     contactNotes: contacts?.contactNotes ?? "",
                                                                     email: contacts?.email ?? ""),
                                  documents: documents ?? [],
                                  notes: notes ?? "",
                                  uuid: uuid,
                                  waitingNumber: waitingNo,
                                  isRead: isRead)
    }

    private func getReason() -> [SCModelAppointmentReason] {
        guard let reasons = self.reasons else {
            return []
        }

        return reasons.filter {
            $0.sNumber != nil && $0.description != nil
        }.map {
            return SCModelAppointmentReason(sNumber: $0.sNumber!, description: $0.description!)
        }
    }

    private func getAttendee() -> [SCModelAppointmentAttendee] {
        guard let attendee = self.attendee else {
            return []
        }

        return attendee.filter {
            $0.firstName != nil && $0.lastName != nil
        }.map {
            return SCModelAppointmentAttendee(firstName: $0.firstName!, lastName: $0.lastName!)
        }
    }
}

protocol AppointmentViewConfigurable {
    var isAddToCalendarAvailable: Bool { get }
    var isQRCodeAvailable: Bool { get }
    var isCancelable: Bool { get }
}

enum AppointmentStatus: String {
    case confirmed = "bestätigung"
    case reservation = "reservierung"
    case rejected = "ablehnung"
    case cancellation = "stornierung"
    case changing = "änderung"
    case none

    struct AppointmentStatusConfig: AppointmentViewConfigurable {
        let viewColor: UIColor
        let statusTextColor: UIColor
        let isQRCodeAvailable: Bool
        let description: String
        let isOverlayHidden: Bool
        let isAddToCalendarAvailable: Bool
        let isCancelable: Bool
    }

    func getConfig(appointmentEndDate: Date?) -> AppointmentStatusConfig {
        switch self {
        case .confirmed:
            if let endDate = appointmentEndDate, endDate.isHistoric() {
                return AppointmentStatusConfig(viewColor: .appointmentExpired,
                                               statusTextColor: .appointmentStatusTextExpired,
                                               isQRCodeAvailable: false,
                                               description: "apnmt_002_item_state_historic".localized(),
                                               isOverlayHidden: false,
                                               isAddToCalendarAvailable: false,
                                               isCancelable: false)
            }

            return AppointmentStatusConfig(viewColor: .clearBackground,
                                           statusTextColor: .appointmentStatusText,
                                           isQRCodeAvailable: true,
                                           description: "",
                                           isOverlayHidden: true,
                                           isAddToCalendarAvailable: true,
                                           isCancelable: true)
        case .reservation:
            return AppointmentStatusConfig(viewColor: .appointmentReservation,
                                           statusTextColor: .appointmentStatusText,
                                           isQRCodeAvailable: false,
                                           description: "apnmt_002_item_state_pending".localized(),
                                           isOverlayHidden: true,
                                           isAddToCalendarAvailable: true,
                                           isCancelable: false)
        case .rejected:
            return AppointmentStatusConfig(viewColor: .appointmentRejected,
                                           statusTextColor: .appointmentStatusText,
                                           isQRCodeAvailable: false,
                                           description: "apnmt_002_item_state_rejected".localized(),
                                           isOverlayHidden: true,
                                           isAddToCalendarAvailable: false,
                                           isCancelable: false)
        case .cancellation:
            return AppointmentStatusConfig(viewColor: .appointmentRejected,
                                           statusTextColor: .appointmentStatusText,
                                           isQRCodeAvailable: false,
                                           description: "apnmt_002_item_state_canceled".localized(),
                                           isOverlayHidden: true,
                                           isAddToCalendarAvailable: false,
                                           isCancelable: false)
        case .none:
            return AppointmentStatusConfig(viewColor: .clearBackground,
                                           statusTextColor: .appointmentStatusText,
                                           isQRCodeAvailable: true,
                                           description: "",
                                           isOverlayHidden: true,
                                           isAddToCalendarAvailable: true,
                                           isCancelable: false)
        case .changing:
            if let endDate = appointmentEndDate, endDate.isHistoric() {
                return AppointmentStatusConfig(viewColor: .appointmentExpired,
                                               statusTextColor: .appointmentStatusTextExpired,
                                               isQRCodeAvailable: false,
                                               description: "apnmt_002_item_state_historic".localized(),
                                               isOverlayHidden: false,
                                               isAddToCalendarAvailable: false,
                                               isCancelable: false)
            }

            return AppointmentStatusConfig(viewColor: .appointmentChanging,
                                           statusTextColor: .appointmentStatusText,
                                           isQRCodeAvailable: true,
                                           description: "apnmt_002_item_state_changing".localized(),
                                           isOverlayHidden: true,
                                           isAddToCalendarAvailable: true,
                                           isCancelable: true)
        }
    }
}

struct SCModelAppointment {
    let apptId: Int
    let title: String
    var apptStatus: AppointmentStatus
    let addressDesc: String

    //street + house number
    let street: String

    //Postal code + place
    let place: String
    let date: String
    let time: String

    let createdDate: Date?
    let startDate: Date?
    let endDate: Date?
    let startTime: String
    let endTime: String

    let reasons: [SCModelAppointmentReason]
    let attendee: [SCModelAppointmentAttendee]
    let contact: SCModelAppointmentContact
    let documents: [String]
    let notes: String

    let uuid: String?
    let waitingNumber: String?
    var isRead: Bool
}

struct SCModelAppointmentReason {
    let sNumber: String
    let description: String
}

struct SCModelAppointmentAttendee {
    let firstName: String
    let lastName: String
}

struct SCModelAppointmentContact {
    let contactDesc: String
    let telephone: String
    let contactNotes: String
    let email: String
}
