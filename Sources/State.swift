//
//  State.swift
//  igloo
//
//  Created by Sébastien Hamel on 2017-12-15.
//  Copyright © 2017 Sébastien Hamel. All rights reserved.
//

import Foundation

public protocol State {
    
    func add<S: Store>(store: S)
}
