//
//  StoreType.swift
//  igloo
//
//  Created by Sébastien Hamel on 2017-08-31.
//  Copyright © 2017 Noosera Inc. All rights reserved.
//

import Foundation
import PromiseKit

public protocol Store: class {
    
    associatedtype ReducerType: Reducer
    
    var reducer: ReducerType { get }
    
    @discardableResult
    func readSync<R>(in dispatchQueue: DispatchQueue, with closure: @escaping () throws -> R) throws -> R
    
    @discardableResult
    func readAsync<R>(in dispatchQueue: DispatchQueue, with closure: @escaping () throws -> R) -> Promise<R>
    
    func async(closure: @escaping () -> Promise<ActionResult?>) -> Promise<ActionResult?>
    
    func async(action: AsyncAction) -> Promise<ActionResult?>
    
    func sync(action: SyncAction) -> ActionResult?
}

extension Store {
    
    @discardableResult
    public func readSync<R>(in dispatchQueue: DispatchQueue, with closure: @escaping () throws -> R) throws -> R {
        
        return try reducer.readSync(store: self, in: dispatchQueue, with: closure)
    }
    
    @discardableResult
    public func readAsync<R>(in dispatchQueue: DispatchQueue, with closure: @escaping () throws -> R) -> Promise<R> {
        
        return reducer.readAsync(store: self, in: dispatchQueue, with: closure)
    }
    
    @discardableResult
    public func async(closure: @escaping () -> Promise<ActionResult?>) -> Promise<ActionResult?> {
        
        return Promise<ActionResult?> { fulfill, reject in
            
            firstly {
                closure()
            }.then { closureResult -> Void in
                fulfill(closureResult)
            }.catch { error in
                debugPrint("Error: \(error)")
                reject(error)
            }
        }
    }
    
    @discardableResult
    public func async(action: AsyncAction) -> Promise<ActionResult?> {
        
        return Promise<ActionResult?> { fulfill, reject in
                
            firstly {
                reducer.async(store: self, action: action)
            }.then { actionResult -> Void in
                fulfill(actionResult)
            }.catch { error in
                debugPrint("Error: \(error)")
                reject(error)
            }
        }
    }
    
    @discardableResult
    public func sync(action: SyncAction) -> ActionResult? {
        
        return reducer.sync(store: self, action: action)
    }
}

