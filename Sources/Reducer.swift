//
//  Reducer.swift
//  igloo
//
//  Created by Sebastien hamel on 2017-08-31.
//  Copyright © 2017 Nebula Media. All rights reserved.
//

import Foundation
import PromiseKit

public protocol Reducer {
    
    func readSync<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping (S) throws -> R) -> Promise<R>
    
    func readAsync<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping (S) throws -> R) -> Promise<R>
    
    func reduce<S: Store>(store: S, action: ActionType, completion closure: ((S, ActionResult?) -> Promise<ActionResult?>)?) -> Promise<ActionResult?>
    
    func handle<S: Store>(store: S, action: ActionType) -> Promise<ActionResult?>
}

extension Reducer {
    
    public func readSync<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping (S) throws -> R) -> Promise<R> {
        
        return Promise<R> { fulfill, reject in
            
            // this is the async read
            dispatchQueue.sync {
                
                do {
                    let r: R = try closure(store)
                    fulfill(r)
                }
                catch let error {
                    reject(error)
                }
            }
        }
    }
    
    public func readAsync<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping (S) throws -> R) -> Promise<R> {
        
        return Promise<R> { fulfill, reject in
            
            // this is the async read
            dispatchQueue.async {
                
                do {
                    let r: R = try closure(store)
                    fulfill(r)
                }
                catch let error {
                    reject(error)
                }
            }
        }
    }
    
    // remove the completion from the reduce.... it should be done at the dispatcher level
    public func reduce<S: Store>(store: S, action: ActionType, completion closure: ((S, ActionResult?) -> Promise<ActionResult?>)? = nil) -> Promise<ActionResult?>  {
        
        return Promise<ActionResult?> { fulfill, reject in
            
            if let closure = closure {
                
                firstly {
                    handle(store: store, action: action)
                }.then { actionResult -> Promise<ActionResult?> in
                    closure(store, actionResult)
                }.then { closureResult -> Void in
                    fulfill(closureResult)
                }.catch { error in
                    debugPrint("Error: \(error)")
                    reject(error)
                }
            }
            else {
                
                firstly {
                    handle(store: store, action: action)
                }.then { actionResult -> Void in
                    fulfill(actionResult)
                }.catch { error in
                    debugPrint("Error: \(error)")
                    reject(error)
                }
            }
        }
    }
    
}

