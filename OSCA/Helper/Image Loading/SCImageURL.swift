//
//  SCImageURLswift
//  SmartCity
//
//  Created by Michael on 21.01.19.
//  Copyright © 2019 Michael. All rights reserved.
//

import UIKit

struct SCImageURL: Codable, Hashable{
    
    /**
     *
     * SCImageURL Class provides information about the imageurl and persistence behaviour
     *
     * @param urlString relative path string for the image (will be delivered by the backen api)
     * @param persistence if TRUE, the image won't be deleted even when the cache will be erased
     */
    private var urlString : String
    private var persistence : Bool = false

    
    static func documentsDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    static func cachesDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }

    init(urlString: String, persistence: Bool)
    {
        self.urlString = urlString
        self.persistence = persistence
    }

    
    func absoluteUrlString() -> String {
        
        return urlString.encodeUrl() ?? ""
    }
    
    func absoluteUrl() -> URL {
        return urlString.absoluteUrl()
    }

    func storagePathforImage() -> String {
        let directory = persistence ? SCImageURL.documentsDir() : SCImageURL.cachesDir()
        return String(format:"%@/%@", directory, self.stripURL(url: self.urlString))
    }

    func canBeStoredLazy() -> Bool {
        return persistence ? false : true
    }
    
    private func stripURL(url:String) -> String {
        return url.replacingOccurrences(of: "/", with: "___", options: NSString.CompareOptions.literal, range: nil)
    }
    
   
    
}
