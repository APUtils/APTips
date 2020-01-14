//
//  Tip.swift
//  APTips
//
//  Created by Anton Plebanovich on 10/16/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation

/// Tip representation.
public struct Tip {
    
    /// Tip's ID that will be used to identify this tip.
    public var id: String
    
    /// Tip's message to show.
    public var message: String
    
    
    /// - Parameters:
    ///   - id: Tip's ID. If `nil` is passed tip's message will be used instead.
    ///   - message: Tip's message.
    public init(id: String? = nil, message: String) {
        self.id = id ?? message
        self.message = message
    }
}
