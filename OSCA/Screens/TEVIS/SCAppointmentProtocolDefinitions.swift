/*
Created by Michael on 01.11.20.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
