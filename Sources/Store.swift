//
//  StoreType.swift
//  igloo
//
//  Created by Sebastien hamel on 2017-08-31.
//  Copyright © 2017 Nebula Media. All rights reserved.
//

import Foundation
import PromiseKit

public protocol Store: class {
    
    associatedtype ReducerType: Reducer
    
    var reducer: ReducerType { get }
    
    @discardableResult
    func readSync<R>(in dispatchQueue: DispatchQueue, with closure: @escaping (Self) throws -> R) -> Promise<R>
    
    @discardableResult
    func readAsync<R>(in dispatchQueue: DispatchQueue, with closure: @escaping (Self) throws -> R) -> Promise<R>
    
    func dispatch(closure: @escaping (Self) -> Promise<ActionResult?>, completion: ((Self, ActionResult?) -> Promise<ActionResult?>)?) -> Promise<ActionResult?>
    
    func dispatch(action: ActionType, completion: ((Self, ActionResult?) -> Promise<ActionResult?>)?) -> Promise<ActionResult?>
}

extension Store {
    
    @discardableResult
    public func readSync<R>(in dispatchQueue: DispatchQueue, with closure: @escaping (Self) throws -> R) -> Promise<R> {
        
        return reducer.readSync(store: self, in: dispatchQueue, with: closure)
    }
    
    @discardableResult
    public func readAsync<R>(in dispatchQueue: DispatchQueue, with closure: @escaping (Self) throws -> R) -> Promise<R> {
        
        return reducer.readAsync(store: self, in: dispatchQueue, with: closure)
    }
    
    public func dispatch(closure: @escaping (Self) -> Promise<ActionResult?>, completion: ((Self, ActionResult?) -> Promise<ActionResult?>)? = nil) -> Promise<ActionResult?> {
        
        return Promise<ActionResult?> { fulfill, reject in
            
            if let completion = completion {
                
                firstly {
                    closure(self)
                }.then { closureResult -> Promise<ActionResult?> in
                    completion(self, closureResult)
                }.then { completionResult -> Void in
                    fulfill(completionResult)
                }.catch { error in
                    debugPrint("Error: \(error)")
                    reject(error)
                }
            }
            else {
                
                firstly {
                    closure(self)
                }.then { closureResult -> Void in
                    fulfill(closureResult)
                }.catch { error in
                    debugPrint("Error: \(error)")
                    reject(error)
                }
            }
        }
    }
    
    @discardableResult
    public func dispatch(action: ActionType, completion: ((Self, ActionResult?) -> Promise<ActionResult?>)? = nil) -> Promise<ActionResult?> {
        
        return Promise<ActionResult?> { fulfill, reject in
                
            firstly {
                reducer.reduce(store: self, action: action, completion: completion)
            }.then { actionResult -> Void in
                fulfill(actionResult)
            }.catch { error in
                debugPrint("Error: \(error)")
                reject(error)
            }
        }
    }
}

