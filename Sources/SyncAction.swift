//
//  SyncAction.swift
//  Igloo
//
//  Created by Sebastien hamel on 2018-03-22.
//

import Foundation


public struct SyncAction: Action {
        
    public let type: ActionType
    
    public init(type: ActionType) {
        
        self.type = type
    }
}
