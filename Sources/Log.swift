//
//  Log.swift
//  Igloo
//
//  Created by Sebastien hamel on 2019-01-02.
//  Copyright © 2019 Textually Inc. All rights reserved.
//

import Foundation
import os

struct Log {
    
    struct Igloo {
        
        static let all = OSLog(subsystem: "net.textually.mac.stylo", category: "default")
        
    }
}
