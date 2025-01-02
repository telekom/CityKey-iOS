//
//  SCEgovSearchHistoryManager.swift
//  OSCA
//
//  Created by Bharat Jagtap on 18/10/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCEgovSearchHistoryManaging {
    
    func addSearchTerm(searchTerm : String, cityId : String?)
    func getAllSearchTerms(cityId : String?) -> [String]
    func clearSearchTerms(for cityId : String?)
    func clearAllSearchTerms()
}


class SCEgovSearchHistoryManager : SCEgovSearchHistoryManaging {
    
    
    private static let termsDictonaryKey = "SCEgovSearchHistoryManager.termsDictonaryKey"
    private static let defaultCityKey = "SCEgovSearchHistoryManager.defaultCityKey"


    func addSearchTerm(searchTerm : String, cityId : String?) {
        
        var termsDic = UserDefaults.standard.dictionary(forKey: SCEgovSearchHistoryManager.termsDictonaryKey) as? [String:[String]] ?? [String: [String]]()
        
        let cityIdKey = cityId ?? SCEgovSearchHistoryManager.defaultCityKey
        var terms = termsDic[cityIdKey] ?? [String]()
        
        if terms.contains(searchTerm) {
        
            if let index = terms.firstIndex(of: searchTerm) {
                let object = terms.remove(at: index)
                terms.insert(object, at: 0)
            }
        } else {
            terms.insert(searchTerm, at: 0)
        }

        if terms.count > 10 {
            terms.removeLast(terms.count - 10)
        }
        termsDic[cityIdKey] = terms
        UserDefaults.standard.set(termsDic, forKey: SCEgovSearchHistoryManager.termsDictonaryKey)
        UserDefaults.standard.synchronize()
    }
    
    func getAllSearchTerms(cityId : String?) -> [String] {
        
        let termsDic = UserDefaults.standard.dictionary(forKey: SCEgovSearchHistoryManager.termsDictonaryKey) as? [String:[String]] ?? [String: [String]]()
        let cityIdKey = cityId ?? SCEgovSearchHistoryManager.defaultCityKey
        return termsDic[cityIdKey] ?? [String]()
    }
    
    func clearSearchTerms(for cityId : String?) {
        
        var termsDic = UserDefaults.standard.dictionary(forKey: SCEgovSearchHistoryManager.termsDictonaryKey) as? [String:[String]] ?? [String: [String]]()
        let cityIdKey = cityId ?? SCEgovSearchHistoryManager.defaultCityKey
        termsDic[cityIdKey] = nil
        UserDefaults.standard.set(termsDic, forKey: SCEgovSearchHistoryManager.termsDictonaryKey)
        UserDefaults.standard.synchronize()
    }
    
    func clearAllSearchTerms() {
        
        UserDefaults.standard.set(nil, forKey: SCEgovSearchHistoryManager.termsDictonaryKey)
        UserDefaults.standard.synchronize()
    }
    
}
