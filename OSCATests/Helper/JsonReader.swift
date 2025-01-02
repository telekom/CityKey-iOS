//
//  JsonReader.swift
//  OSCATests
//
//  Created by Bhaskar N S on 10/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

class JsonReader {
    func readJsonFrom(fileName: String?, withExtension: String?) -> Data {
        guard let path = Bundle(for: type(of: self)).url(forResource: fileName,
                                                         withExtension: withExtension) else {
            return Data()
        }
        do {
            return try Data(contentsOf: path)
        } catch {
            return Data()
        }
    }
    
    func parseJsonData<T: Decodable>(of type: T.Type, data: Data) -> T? {
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch let error {
            print("\(error)")
        }
        return nil
    }
}
