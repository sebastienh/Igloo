//
//  Reducer.swift
//  igloo
//
//  Created by Sébastien Hamel on 2017-08-31.
//  Copyright © 2017 Textually Inc. All rights reserved.
//

import Foundation
import PromiseKit

public protocol Reducer {
    
    func readSync<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping () throws -> R) throws -> R
    
    func readAsync<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping () throws -> R) -> Promise<R>
    
    func sync<S: Store>(store: S, action: SyncAction) -> ActionResult?
    
    func async<S: Store>(store: S, action: AsyncAction) -> Promise<ActionResult?>
}

extension Reducer {
    
    public func readSync<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping () throws -> R) throws -> R {
        
        var r: R?
        
        // this is the async read
        try dispatchQueue.sync {
            
            r = try closure()
        }
        return r!
    }
    
    public func readAsync<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping () throws -> R) -> Promise<R> {
        
        return Promise<R> { fulfill, reject in
            
            // this is the async read
            dispatchQueue.async {
                
                do {
                    let r: R = try closure()
                    fulfill(r)
                }
                catch let error {
                    reject(error)
                }
            }
        }
    }
    
}

