//
//  IglooKitTests.swift
//  IglooKit
//
//  Created by Sebastien hamel on 2017-12-16.
//

import XCTest
import IglooKit
import PromiseKit

class IglooKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateStore() {
        
        class MyReducer: Reducer {
            
            func handle<S>(store: S, action: ActionType) -> Promise<Void> where S : Store {
                return Promise<Void> { fulfill, reject in
                    fulfill(())
                }
            }
        }
        
        final class MyStore: Store {
            
            var reducer: MyReducer
            
            var pendingStoreClosures: [(((MyStore) -> Bool), (MyStore) -> Promise<Void>, ((MyStore) -> Promise<Void>)?)]
            
            var pendingStoreActions: [(((MyStore) -> Bool), ActionType, ((MyStore) -> Promise<Void>)?)]
            
            
            typealias ReducerType = MyReducer
            
            init() {
                
                self.pendingStoreClosures = [(((MyStore) -> Bool), (MyStore) -> Promise<Void>, ((MyStore) -> Promise<Void>)?)]()
                
                self.pendingStoreActions =  [(((MyStore) -> Bool), ActionType, ((MyStore) -> Promise<Void>)?)]()
                
                self.reducer = MyReducer()
            }
            
        }
        
        let store = MyStore()
        
        XCTAssert(store != nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
