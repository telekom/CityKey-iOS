//
//  SCQRCodePresenter.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 29/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCQRCodePresenting {
    func getQRCodeImage() -> UIImage?
    func getWaitingNumber() -> String?
}

class SCQRCodePresenter {

    let appointment: SCModelAppointment

    init(appointment: SCModelAppointment) {
        self.appointment = appointment
    }
}

extension SCQRCodePresenter: SCQRCodePresenting {

    func getQRCodeImage() -> UIImage? {
        if let uuid = appointment.uuid {
            return QRCodeGenerator.getQRCode(from: uuid)
        }
        return nil
    }

    func getWaitingNumber() -> String? {
        return appointment.waitingNumber
    }
}
