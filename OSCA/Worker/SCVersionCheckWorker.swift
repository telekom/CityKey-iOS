//
//  SCVersionCheckWorker
//  SmartCity
//
//  Created by Michael on 23.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//
import Foundation

protocol SCVersionCheckWorking {
    func checkVersionInfo(completion: @escaping ((_ error : SCWorkerError?, _ versionSupported: Bool, _ unspportedVersionMessage: String?) -> Void))
}

class SCVersionCheckWorker: SCWorker, SCVersionCheckWorking {
    
    let versionApiPath = "/api/v2/smartcity/city/appVersion"
    
    public func checkVersionInfo(completion: @escaping ((_ error : SCWorkerError?, _ versionSupported: Bool, _ unspportedVersionMessage: String?) -> Void)) {
#if INT
        let cityID = "10"
#else
        let cityID = "8"
#endif
        let queryParameter = ["cityId": cityID,
                              "actionName": "GET_AppVersion",
                              "appVersion": "\(SCVersionHelper.appVersion())",
                              "osName": "iOS"]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: versionApiPath, parameter: queryParameter)
        
        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (response) in
            switch response {
                
            case .success(let fetchedData):
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: fetchedData, options:[]) as? Dictionary<String,AnyObject>
                    print("Json: \(String(describing: jsonData))")
                    if let contentArray = jsonData?["content"] as? NSArray {
                        if let dict = contentArray[0] as? Dictionary<String,AnyObject> {
                            if dict["result"] as! String == "SUCCESS" {
                                completion(nil, true, nil)
                            } else {
                                completion(nil, false, nil)
                            }
                        }
                    }
                }
                catch {
                    print("Not Serialized")
                }
            case .failure(let error):
                switch error {
                case .requestFailed(_ , _):
                    // We are not handling error for GET_AppVersion API, so that user will not be blocked from using the application
                    completion(nil, true, nil)
                default:
                    completion(nil, true, nil)
                }
            }
        }
    }
}

