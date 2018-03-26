//
//  Action.swift
//  Igloo
//
//  Created by Sebastien hamel on 2018-03-22.
//

import Foundation

public typealias DomainName = String

public protocol Action {
    
    var type: ActionType { get }
    
    // var domains: [DomainName: DomainPermissions] { get }
}

