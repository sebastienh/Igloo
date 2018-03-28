//
//  DomainPermissions.swift
//  Igloo
//
//  Created by Sebastien hamel on 2018-03-22.
//

import Foundation

public struct DomainPermissions: Permissions {
    
    var domainName: DomainName
    
    var read: Bool
    
    var write: Bool
    
    init(domainName: DomainName, read: Bool, write: Bool) {
        
        self.domainName = domainName
        self.read = read
        self.write = write
    }
}
