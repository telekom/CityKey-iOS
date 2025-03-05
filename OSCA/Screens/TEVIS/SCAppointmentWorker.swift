/*
Created by Rutvik Kanbargi on 16/07/20.
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

import Foundation

protocol SCAppointmentWorking {
    func getAppointments(for cityId: String,
                         completion: @escaping (([SCModelAppointment]?, SCWorkerError?) -> Void))
    func cancelAppointment(for cityId: String,
                           uuid: String,
                           completion: @escaping ((SCWorkerError?) -> Void))
    func deleteAppointments(for cityId: String,
                            appointmentId: Int,
                            status: Bool,
                            completion: @escaping ((SCWorkerError?) -> Void))
    func markAppointmentsAsRead(for cityId: String,
                                appointmentIds: [Int],
                                completion: @escaping ((SCWorkerError?) -> Void))
}

class SCAppointmentWorker: SCWorker {
    private let appointmentsApiPath = "/api/v2/smartcity/city/apptService"
}

extension SCAppointmentWorker: SCAppointmentWorking {

    func getAppointments(for cityId: String,
                         completion: @escaping (([SCModelAppointment]?, SCWorkerError?) -> Void)) {
        let queryDictionary = ["cityId": cityId,
                               "actionName": "GET_UserAppt"] as [String : String]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.appointmentsApiPath,
                                                        parameter: queryDictionary)

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: true) { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    let appointmentData = try JSONDecoder().decode(SCHttpModelResponse<[SCHttpModelAppointment]>.self, from: fetchedData)
                    let appointments = appointmentData.content.map { $0.toModel() }
                    completion(appointments, nil)
                } catch {
                    completion(nil, SCWorkerError.technicalError)
                }

            case .failure(let error):
                debugPrint("SCAppointmentWorker: requestFailed", error)
                completion(nil, self.mapRequestError(error))
            }
        }
    }

    func cancelAppointment(for cityId: String,
                           uuid: String,
                           completion: @escaping ((SCWorkerError?) -> Void)){
        
        let queryDictionary = ["cityId": cityId,
                               "actionName": "PUT_CancelUserAppt",
                               "id": uuid]

        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.appointmentsApiPath,
                                                        parameter: queryDictionary)

        request.fetchData(from: url, method: "PUT", body: nil, needsAuth: true) { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    _ = try JSONDecoder().decode(SCHttpModelBaseResponse.self, from: fetchedData)
                    completion(nil)
                } catch {
                    completion(SCWorkerError.technicalError)
                }

            case .failure(let error):
                debugPrint("SCAppointmentWorker: requestFailed", error)
                completion(self.mapRequestError(error))
            }
        }

    }

    func deleteAppointments(for cityId: String, appointmentId: Int,
                            status: Bool,
                            completion: @escaping ((SCWorkerError?) -> Void)) {
        let queryDictionary = ["cityId": cityId,
                               "actionName": "PUT_UserAppt",
                               "isDelete" : String(status),
                               "apptId": "\(appointmentId)"] as [String : String]

        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.appointmentsApiPath,
                                                        parameter: queryDictionary)

        request.fetchData(from: url, method: "PUT", body: nil, needsAuth: true) { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    _ = try JSONDecoder().decode(SCHttpModelBaseResponse.self, from: fetchedData)
                    completion(nil)
                } catch {
                    completion(SCWorkerError.technicalError)
                }

            case .failure(let error):
                debugPrint("SCAppointmentWorker: requestFailed", error)
                completion(self.mapRequestError(error))
            }
        }
    }
    
    
    func markAppointmentsAsRead(for cityId: String,
                                appointmentIds: [Int],
                                completion: @escaping ((SCWorkerError?) -> Void))
    {
        let queryDictionary = ["cityId": cityId,
                               "actionName": "PUT_ApptReadStatus",
                               "apptIds": appointmentIds.map { String($0) }.joined(separator:",")] as [String : String]

        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.appointmentsApiPath,
                                                        parameter: queryDictionary)

        request.fetchData(from: url, method: "PUT", body: nil, needsAuth: true) { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    _ = try JSONDecoder().decode(SCHttpModelBaseResponse.self, from: fetchedData)
                    completion(nil)
                } catch {
                    completion(SCWorkerError.technicalError)
                }

            case .failure(let error):
                debugPrint("SCAppointmentWorker: requestFailed", error)
                completion(self.mapRequestError(error))
            }
        }
    }

}
