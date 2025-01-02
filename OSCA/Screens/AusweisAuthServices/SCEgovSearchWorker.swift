//
//  SCEgovSearchWorker.swift
//  OSCA
//
//  Created by Bharat Jagtap on 18/10/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
