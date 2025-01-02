//
//  NSPointerArray+WeakObjRef.swift
//  SmartCity
//
//  Created by Michael on 08.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import Foundation

/**
 *
 * Extension store weak objects like delegates in an array
 *
 */
extension NSPointerArray {
    func addObject(_ object: AnyObject?) {
        guard let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        addPointer(pointer)
    }
    
    func insertObject(_ object: AnyObject?, at index: Int) {
        guard index < count, let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        insertPointer(pointer, at: index)
    }
    
    func replaceObject(at index: Int, withObject object: AnyObject?) {
        guard index < count, let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        replacePointer(at: index, withPointer: pointer)
    }
    
    func object(at index: Int) -> AnyObject? {
        guard index < count, let pointer = self.pointer(at: index) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
    }
    
    func removeObject(at index: Int) {
        guard index < count else { return }
        
        removePointer(at: index)
    }
}
