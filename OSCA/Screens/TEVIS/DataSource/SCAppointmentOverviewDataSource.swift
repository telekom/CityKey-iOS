//
//  SCAppointmentOverviewDataSource.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 20/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCAppointmentOverviewDelegate: AnyObject {
    func didSelected(appointment: SCModelAppointment)
    func didTapOnQRCode(appointment: SCModelAppointment)
}

protocol SCAppointmentOverviewDataSourceDelegate: AnyObject {
    func deleteAppointment(at index: Int)
    func showToasteWith(message: String)
}

class SCAppointmentOverviewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    private var appointments: [SCModelAppointment]

    private weak var delegate: (SCAppointmentOverviewDelegate & SCAppointmentOverviewDataSourceDelegate)?

    init(appointments: [SCModelAppointment],
         delegate: SCAppointmentOverviewDelegate & SCAppointmentOverviewDataSourceDelegate) {
        self.appointments = appointments
        self.delegate = delegate
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = String(describing: SCAppointmentOverviewTableViewCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SCAppointmentOverviewTableViewCell else {
            return UITableViewCell()
        }

        let appointment = appointments[indexPath.section]
        cell.set(appointment: appointment, delegate: delegate, dataSourceDelegate: self, indexPath: indexPath)
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return appointments.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 11
        }
        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return UIView()
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == appointments.count - 1 {
            let view = UIView()
            view.backgroundColor = .clear
            return UIView()
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == appointments.count - 1 {
            return 11
        }
        return 0
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if UIAccessibility.isVoiceOverRunning {
            return true
        }

        return false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if UIAccessibility.isVoiceOverRunning && editingStyle == .delete {
            deleteAppointment(at: indexPath, tableView: tableView)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SCAppointmentOverviewTableViewCell {
            cell.didTapOnMoreInfo(cell.moreInfoButton)
        }
    }
}

extension SCAppointmentOverviewDataSource: SCAppointmentOverviewDataSourceCellDelegate {

    func deleteAppointment(at indexPath: IndexPath, tableView: UITableView) {
        let appointment = appointments[indexPath.section]
        if (appointment.endDate?.isHistoric() == true)
            || (appointment.apptStatus == .rejected)
            || (appointment.apptStatus == .cancellation) {
            let index = indexPath.section
            let indexSet = IndexSet(integer: index)
            tableView.beginUpdates()
            self.appointments.remove(at: index)
            tableView.deleteSections(indexSet, with: .fade)
            tableView.endUpdates()
            self.delegate?.deleteAppointment(at: index)
        } else if appointment.apptStatus == .confirmed || appointment.apptStatus == .reservation {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            self.delegate?.showToasteWith(message: LocalizationKeys.SCAppointmentOverviewDataSource.apnmtDeleteNotAllowed.localized())
        }
    }
}

