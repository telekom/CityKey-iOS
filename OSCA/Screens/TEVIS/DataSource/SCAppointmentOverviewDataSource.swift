/*
Created by Rutvik Kanbargi on 20/07/20.
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

