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
    
    func read<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping (S) throws -> R) -> Promise<R>
    
    func reduce<S: Store>(store: S, action: ActionType, completion closure: ((S) -> Promise<Void>)?) -> Promise<Void>
    
    func handle<S: Store>(store: S, action: ActionType) -> Promise<Void>
}

extension Reducer {
    
    public func read<S: Store, R>(store: S, in dispatchQueue: DispatchQueue, with closure: @escaping (S) throws -> R) -> Promise<R> {
        
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
    public func reduce<S: Store>(store: S, action: ActionType, completion closure: ((S) -> Promise<Void>)? = nil) -> Promise<Void>  {
        
        return Promise<Void> { fulfill, reject in
            
            if let closure = closure {
                
                firstly {
                    handle(store: store, action: action)
                    }.then {
                        closure(store)
                    }.then {
                        fulfill(())
                    }.catch { error in
                        debugPrint("Error: \(error)")
                        reject(error)
                }
            }
            else {
                
                firstly {
                    handle(store: store, action: action)
                    }.then {
                        fulfill(())
                    }.catch { error in
                        debugPrint("Error: \(error)")
                        reject(error)
                }
            }
        }
    }
    
}
