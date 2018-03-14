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
    
    var pendingStoreClosures: [(((Self) -> Bool), (Self) -> Promise<ActionResult?>, ((Self, ActionResult?) -> Promise<ActionResult?>)?)] { get set }
    
    var pendingStoreActions: [(((Self) -> Bool), ActionType, ((Self, ActionResult?) -> Promise<ActionResult?>)?)] { get set }
    
    @discardableResult
    func readSync<R>(in dispatchQueue: DispatchQueue, with closure: @escaping (Self) throws -> R) -> Promise<R>
    
    @discardableResult
    func readAsync<R>(in dispatchQueue: DispatchQueue, with closure: @escaping (Self) throws -> R) -> Promise<R>
    
    func dispatch(closure: @escaping (Self) -> Promise<ActionResult?>, condition: ((Self) -> Bool)?, completion: ((Self, ActionResult?) -> Promise<ActionResult?>)?) -> Promise<ActionResult?>
    
    func dispatch(action: ActionType, condition: ((Self) -> Bool)?, completion: ((Self, ActionResult?) -> Promise<ActionResult?>)?) -> Promise<ActionResult?>
    
    func executeExecutablePendingStoreClosures() -> Promise<Void>
    
    func executeExecutablePendingStoreActions() -> Promise<Void>
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
    
    public func dispatch(closure: @escaping (Self) -> Promise<ActionResult?>, condition: ((Self) -> Bool)? = nil, completion: ((Self, ActionResult?) -> Promise<ActionResult?>)? = nil) -> Promise<ActionResult?> {
        
        return Promise<ActionResult?> { fulfill, reject in
            
            if let condition = condition {
                
                if condition(self) {
                    
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
                else {
                    pendingStoreClosures.append((condition, closure, completion))
                    fulfill(nil)
                }
            }
            else {
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
    }
    
    @discardableResult
    public func dispatch(action: ActionType, condition: ((Self) -> Bool)? = nil, completion: ((Self, ActionResult?) -> Promise<ActionResult?>)? = nil) -> Promise<ActionResult?> {
        
        return Promise<ActionResult?> { fulfill, reject in
            
            if let condition = condition {
                
                if condition(self) {
                    
                    firstly {
                        reducer.reduce(store: self, action: action, completion: completion)
                    }.then { actionResult -> Void in
                        fulfill(actionResult)
                    }.catch { error in
                        debugPrint("Error: \(error)")
                        reject(error)
                    }
                }
                else {
                    pendingStoreActions.append((condition, action, completion))
                    fulfill(nil)
                }
            }
            else {
                
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
    
    // validate if any pendingStoreClosures can be run and execute
    // them if they are.
    public func executeExecutablePendingStoreClosures() -> Promise<Void> {
        
        return Promise<Void> { fulfill, reject in
            
            var executedPendingStoreClosuresIndexes = [Int]()
            var lastPromise: Promise<ActionResult?>? = nil
            
            for (index, (condition, closure, completion)) in pendingStoreClosures.enumerated() {
                
                if condition(self) {
                    
                    if let _lastPromise = lastPromise {
                        
                        _lastPromise.then { (_) -> Promise<ActionResult?> in
                            
                            lastPromise = self.dispatch(closure: closure, condition: nil, completion: completion)
                            executedPendingStoreClosuresIndexes.append(index)
                            return lastPromise!
                        }.catch { error -> Void in
                            debugPrint("Error: \(error)")
                            reject(error)
                        }
                    }
                    else {
                        lastPromise = self.dispatch(closure: closure, condition: nil, completion: completion)
                        executedPendingStoreClosuresIndexes.append(index)
                    }
                }
            }
            
            if let lastPromise = lastPromise {
                
                // FIXME: need to understand why we an not put this in the then...
                // we don't really care but the fact is we like to understand why things
                // are the way they are.
                self.deleteExecutedPendingStoreClosures(indexes: executedPendingStoreClosuresIndexes)
                
                lastPromise.then { (_) -> Void in
                    fulfill(())
                }.catch { error in
                    debugPrint("Error: \(error)")
                    reject(error)
                }
            } else {
                
                assert(executedPendingStoreClosuresIndexes.count == 0)
                fulfill(())
            }
        }
    }
    
    public func executeExecutablePendingStoreActions() -> Promise<Void> {
        
        return Promise<Void> { fulfill, reject in
            
            var executedPendingStoreActionsIndexes = [Int]()
            var lastPromise: Promise<ActionResult?>? = nil
            
            for (index, (condition, action, completion)) in pendingStoreActions.enumerated() {
                
                if condition(self) {
                    
                    if let _lastPromise = lastPromise {
                        
                        _lastPromise.then { _  -> Promise<ActionResult?> in
                            
                            lastPromise = self.dispatch(action: action, condition: nil, completion: completion)
                            executedPendingStoreActionsIndexes.append(index)
                            return lastPromise!
                        }.catch { error in
                            debugPrint("Error: \(error)")
                            reject(error)
                        }
                    }
                    else {
                        lastPromise = self.dispatch(action: action, condition: nil, completion: completion)
                        executedPendingStoreActionsIndexes.append(index)
                    }
                }
            }
            
            if let lastPromise = lastPromise {
                
                self.deleteExecutedPendingStoreActions(indexes: executedPendingStoreActionsIndexes)
                
                lastPromise.then {_ -> Void in
                    fulfill(())
                }.catch { error in
                    debugPrint("Error: \(error)")
                    reject(error)
                }
            } else {
                
                assert(executedPendingStoreActionsIndexes.count == 0)
                fulfill(())
            }
        }
    }
    
    private func deleteExecutedPendingStoreClosures(indexes: [Int]) {
        
        var _reversedIndexes: [Int] = indexes.reversed()
        var removedValues = 0
        
        while !_reversedIndexes.isEmpty {
            
            let lastIndex = _reversedIndexes.first!
            pendingStoreClosures.remove(at: lastIndex - removedValues)
            _reversedIndexes.remove(at: lastIndex - removedValues)
            removedValues += 1
        }
    }
    
    private func deleteExecutedPendingStoreActions(indexes: [Int]) {
        
        var _reversedIndexes: [Int] = indexes.reversed()
        var removedValues = 0
        
        while !_reversedIndexes.isEmpty {
            
            let lastIndex = _reversedIndexes.first!
            pendingStoreActions.remove(at: lastIndex - removedValues)
            _reversedIndexes.remove(at: lastIndex - removedValues)
            removedValues += 1
        }
    }
}

