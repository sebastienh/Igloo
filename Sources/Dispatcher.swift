//
//  Dispatcher.swift
//  igloo
//
//  Created by Sébastien Hamel on 2017-11-12.
//  Copyright © 2017 Textually Inc. All rights reserved.
//

import Foundation
import PromiseKit

public protocol Dispatcher {
    
    var state: State { get }
    
    @discardableResult
    func readSync<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping () throws -> R) throws -> R
    
    @discardableResult
    func readAsync<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping () throws -> R) -> Promise<R>
    
    /// Dispatch the action in the right store
    /// we should not put the completion in the pending tasks. They should
    /// only include the old task and not containing the completion which
    /// also has to be run at each time. So the code to handle the completion should
    /// really be written in each action.
    @discardableResult
    func async<S: Store>(store: S, action: AsyncAction) -> Promise<ActionResult?>
    
    @discardableResult
    func sync<S: Store>(store: S, action: SyncAction) -> ActionResult?
    
    @discardableResult
    func async<S: Store>(store: S, closure: @escaping () -> Promise<ActionResult?>) -> Promise<ActionResult?>
    
    func register<S: Store>(store: S)
}

extension Dispatcher {
    
    @discardableResult
    public func readSync<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping () throws -> R) throws -> R {
        
        return try store.readSync(in: dispatchQueue, with: closure)
    }
    
    @discardableResult
    public func readAsync<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping () throws -> R) -> Promise<R> {
        
        return store.readAsync(in: dispatchQueue, with: closure)
    }
    
    /// Dispatch the action in the right store
    /// we should not put the completion in the pending tasks. They should
    /// only include the old task and not containing the completion which
    /// also has to be run at each time. So the code to handle the completion should
    /// really be written in each action.
    @discardableResult
    public func async<S: Store>(store: S, action: AsyncAction) -> Promise<ActionResult?> {
        
        return Promise<ActionResult?> { fulfill, reject in
                
            // if there is no condition we execute simply the closure, followed with
            // the completion and finally all the pending tasks closures.
            firstly {
                store.async(action: action)
            }.then { actionResult -> Void in
                fulfill(actionResult)
            }.catch { error in
                debugPrint("Error: \(error)")
                reject(error)
            }
        }
    }
    
    @discardableResult
    public func sync<S: Store>(store: S, action: SyncAction) -> ActionResult? {
        
        return store.sync(action: action)
    }
    
    @discardableResult
    public func async<S: Store>(store: S, closure: @escaping () -> Promise<ActionResult?>) -> Promise<ActionResult?> {
        
        return Promise<ActionResult?> { fulfill, reject in
            
            // if there is no condition we execute simply the closure, followed with
            // the completion and finally all the pending tasks closures.
            firstly {
                store.async(closure: closure)
            }.then { actionResult in
                fulfill(actionResult)
            }.catch { error in
                debugPrint("Error: \(error)")
                reject(error)
            }
        }
    }
    
    public func register<S: Store>(store: S) {
        
        state.add(store: store)
    }
    
}

