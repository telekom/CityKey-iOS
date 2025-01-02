//
//  SCAppointmentWorker.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 16/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
