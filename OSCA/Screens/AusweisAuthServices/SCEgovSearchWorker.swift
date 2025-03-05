//
//  SCEgovSearchWorker.swift
//  OSCA
//
//  
//
/*
Created by Bharat Jagtap on 18/10/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bharat Jagtap
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation

protocol SCEgovSearchWorking {
    
    func searchFor(text : String)
    func clearSearch()
    var searchResult : SCDynamicObject<SCEgovSearchResult> { get }
}

enum SCEgovSearchStatus {
    case notTriggered
    case searching
    case success
    case failed
}

struct SCEgovSearchResult {
    
    let searchText: String
    let result : [SCModelEgovService]?
    let status : SCEgovSearchStatus
    let error : Error?
}

class SCEgovSearchWorker : SCEgovSearchWorking {
    
    private var services : [SCModelEgovService]
    var searchResult : SCDynamicObject<SCEgovSearchResult> = SCDynamicObject(SCEgovSearchResult(searchText: "" ,result: nil, status: .notTriggered , error: nil))
    
    init(services : [SCModelEgovService]) {
        self.services = services
    }
    
    func searchFor(text : String) {
        
        let searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard searchText.count > 2 else { return }
        
        let searchTerms = searchText.components(separatedBy: " ").map {  $0.lowercased() }.filter { !$0.elementsEqual("")}
        guard searchTerms.count > 0 else { return }
        
        var searchResultArray = [SCModelEgovService]()

        services.forEach { service in
            
            var termsFoundCount = 0 ;
            
            for term in searchTerms {
                
                var itemsToSearch = [service.serviceName.lowercased(), service.serviceDetail.lowercased(), service.shortDescription.lowercased()]
                itemsToSearch.append(contentsOf: service.searchKey.map {$0.lowercased()} )
                if let groupName = service.groupName { itemsToSearch.append(groupName.lowercased())}
                let searchResult = searchTerm(textItems: itemsToSearch , term: term.trimmingCharacters(in: .whitespacesAndNewlines))
                if searchResult { termsFoundCount += 1}
            }
            
            if termsFoundCount == searchTerms.count { searchResultArray.append(service) }
         }
        
        let uniqueResultArray = filterUnique(array: searchResultArray)
        let sortedResultArray = uniqueResultArray.sorted(by:  { $0.serviceName < $1.serviceName })
        searchResult.value = SCEgovSearchResult(searchText: text ,result: sortedResultArray, status: .success, error: nil)
    
    }
    
    func clearSearch() {
        
        searchResult =  SCDynamicObject(SCEgovSearchResult(searchText: "" ,result: nil, status: .success, error: nil))
    }
    
    private func searchTerm( textItems : [String], term: String) -> Bool {
        guard term.count > 0 else { return false }
        var found = false
        for item in textItems {
            
            if item.contains(term) {
                found = true
                break
            }
        }
        return found
    }
    
    private func filterUnique(array : [SCModelEgovService]) -> [SCModelEgovService] {
        var seen = Set<String>()
        var unique = [SCModelEgovService]()
        for service in array {
            if !seen.contains(service.serviceName) {
                unique.append(service)
                seen.insert(service.serviceName)
            }
        }
        return unique
    }
}
