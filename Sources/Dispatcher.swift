//
//  Dispatcher.swift
//  igloo
//
//  Created by Sebastien hamel on 2017-11-12.
//  Copyright © 2017 Nebula Media. All rights reserved.
//

import Foundation
import PromiseKit

public protocol Dispatcher {
    
    var state: State { get }
    
    @discardableResult
    func read<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping (S) throws -> R) -> Promise<R>
    
    /// Dispatch the action in the right store
    /// we should not put the completion in the pending tasks. They should
    /// only include the old task and not containing the completion which
    /// also has to be run at each time. So the code to handle the completion should
    /// really be written in each action.
    @discardableResult
    func dispatch<S: Store>(store: S, action: ActionType, condition: ((S) -> Bool)?, completion: ((S) -> Promise<Void>)?) -> Promise<Void>
    
    @discardableResult
    func dispatch<S: Store>(store: S, closure: @escaping (S) -> Promise<Void>, condition: ((S) -> Bool)?, completion: ((S) -> Promise<Void>)?) -> Promise<Void>
    
    func pendingTasks<S: Store>(store: S) -> (() -> Promise<Void>)
    
    func register<S: Store>(store: S)
}

extension Dispatcher {
    
    @discardableResult
    public func read<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping (S) throws -> R) -> Promise<R> {
        
        return store.read(in: dispatchQueue, with: closure)
    }
    
    /// Dispatch the action in the right store
    /// we should not put the completion in the pending tasks. They should
    /// only include the old task and not containing the completion which
    /// also has to be run at each time. So the code to handle the completion should
    /// really be written in each action.
    @discardableResult
    public func dispatch<S: Store>(store: S, action: ActionType, condition: ((S) -> Bool)? = nil, completion: ((S) -> Promise<Void>)? = nil) -> Promise<Void> {
        
        return Promise<Void> { fulfill, reject in
            
            if let condition = condition {
                
                if condition(store) {
                    
                    firstly {
                        // remove the handling of the completion it<s already handled here
                        // because the pending task puts it inside the pending tasks, and execute
                        // this task first./
                        store.dispatch(action: action, condition: nil, completion: completion)
                        }.then {
                            self.pendingTasks(store: store)()
                        }.then {
                            fulfill(())
                        }.catch { error in
                            debugPrint("Error: \(error)")
                            reject(error)
                    }
                }
                else {
                    // keep the pending task for later
                    store.pendingStoreActions.append((condition, action, completion))
                    fulfill(())
                }
            }
            else {
                
                // if there is no condition we execute simply the closure, followed with
                // the completion and finally all the pending tasks closures.
                firstly {
                    store.dispatch(action: action, condition: nil, completion: completion)
                    }.then {
                        self.pendingTasks(store: store)()
                    }.then {
                        fulfill(())
                    }.catch { error in
                        debugPrint("Error: \(error)")
                        reject(error)
                }
            }
        }
    }
    
    @discardableResult
    public func dispatch<S: Store>(store: S, closure: @escaping (S) -> Promise<Void>, condition: ((S) -> Bool)?, completion: ((S) -> Promise<Void>)? = nil) -> Promise<Void> {
        
        return Promise<Void> { fulfill, reject in
            
            if let condition = condition {
                
                if condition(store) {
                    
                    firstly {
                        store.dispatch(closure: closure, condition: nil, completion: completion)
                        }.then {
                            self.pendingTasks(store: store)()
                        }.then {
                            fulfill(())
                        }.catch { error in
                            debugPrint("Error: \(error)")
                            reject(error)
                    }
                }
                else {
                    // keep the pending task for later
                    store.pendingStoreClosures.append((condition, closure, completion))
                    fulfill(())
                }
            }
            else {
                
                // if there is no condition we execute simply the closure, followed with
                // the completion and finally all the pending tasks closures.
                firstly {
                    store.dispatch(closure: closure, condition: nil, completion: completion)
                    }.then {
                        self.pendingTasks(store: store)()
                    }.then {
                        fulfill(())
                    }.catch { error in
                        debugPrint("Error: \(error)")
                        reject(error)
                }
            }
        }
    }
    
    public func pendingTasks<S: Store>(store: S) -> (() -> Promise<Void>) {
        
        // Default handling when there is not coordination
        // between stores
        let pendingTasksClosure = { () -> Promise<Void> in
            
            return Promise<Void> { fulfill, reject in
                
                firstly {
                    store.executeExecutablePendingStoreClosures()
                    }.then {
                        store.executeExecutablePendingStoreActions()
                    }.then {
                        fulfill(())
                    }.catch { error in
                        debugPrint("Error: \(error)")
                        reject(error)
                }
            }
        }
        
        return pendingTasksClosure
    }
    
    public func register<S: Store>(store: S) {
        
        state.add(store: store)
    }
    
}

