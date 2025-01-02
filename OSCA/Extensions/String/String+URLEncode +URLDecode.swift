//
//  String+URLEncode +URLDecode.swift
//  SmartCity
//
//  Created by Michael on 15.12.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

extension String
{

    func encodeUrl() -> String?
    {
        return self.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlAllowed) ?? ""
    }
    
    func decodeUrl() -> String?
    {
        return self.removingPercentEncoding
    }
}

extension CharacterSet {
    static let urlAllowed = CharacterSet.urlFragmentAllowed
        .union(.urlHostAllowed)
        .union(.urlPasswordAllowed)
        .union(.urlQueryAllowed)
        .union(.urlUserAllowed)
        .union(.punctuationCharacters)
}
