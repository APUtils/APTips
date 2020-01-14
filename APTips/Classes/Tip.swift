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
    
    // ******************************* MARK: - Display Mode
    
    /// Display mode for a tip.
    public enum DisplayMode {
        
        /// Tip will be displayed from a source center.
        case center
        
        /// Tip will be displayed from a source top or bottom side.
        case side
    }
    
    // ******************************* MARK: - Properties
    
    /// Tip's ID that will be used to identify this tip.
    public var id: String
    
    /// Tip's message to show.
    public var message: String
    
    public var displayMode: DisplayMode
    
    
    /// - Parameters:
    ///   - id: Tip's ID. If `nil` is passed tip's message will be used instead.
    ///   - message: Tip's message.
    public init(id: String? = nil, message: String, displayMode: DisplayMode) {
        self.id = id ?? message
        self.message = message
        self.displayMode = displayMode
    }
}
