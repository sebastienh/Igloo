//
//  Domain.swift
//  Igloo
//
//  Created by Sébastien Hamel on 2018-03-22.
//

import Foundation
import Common

protocol Domain {
    
    var name: String { get }
    
    var queue: DispatchQueue { get }
    
    var ordering: Int { get }
    
    func setValue<T>(for property: Dynamic<T>, permissions: DomainPermissions) throws
    
    func getValue<T>(for property: Dynamic<T>, permissions: DomainPermissions) -> T
}

extension Domain {
    
    func setValue<T>(for property: Dynamic<T>, permissions: DomainPermissions) throws {
        
        assert(permissions.domainName == name)
        assert(permissions.write)
        
        guard permissions.domainName == name else {
            throw IglooError.custom(message: "Wrong domain persmissions used, expect: \(name), received: \(permissions.domainName)")
        }
        
        guard permissions.write else {
            throw IglooError.custom(message: "Write to domain: \(name), is not allowed.")
        }
        
        fatalError("missing implementation")
    }
    
    func getValue<T>(for property: Dynamic<T>, permissions: DomainPermissions) -> T {
        
        fatalError("missing implementation")
        
    }
    
    
}
