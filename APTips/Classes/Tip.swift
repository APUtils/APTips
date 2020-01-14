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
    
    // ******************************* MARK: - Enums
    
    /// Pointing mode for a tip.
    public enum PointingMode {
        
        /// Tip will be displayed from a source center.
        case center
        
        /// Tip will be displayed from a source top or bottom side.
        case side
    }
    
    /// Show mode for a tip.
    public enum ShowMode {
        
        /// Always an immediatelly show a tip.
        case always
        
        /// Show once after 1s delay.
        case once
        
        /// Show once after 1s delay and assure there won't be more than one tip of that type per app launch.
        case onceAndOncePerLaunch
    }
    
    // ******************************* MARK: - Properties
    
    /// Tip's ID that will be used to identify this tip.
    public var id: String
    
    /// Tip's message to show.
    public var message: String
    
    /// Specifies tip's pointing point.
    public var pointingMode: PointingMode
    
    ///  Specifies how tip will be shown.
    public var showMode: ShowMode
    
    
    /// - Parameters:
    ///   - id: Tip's ID. If `nil` is passed tip's message will be used instead.
    ///   - message: Tip's message.
    ///   - pointingMode: Tip's pointing mode.
    ///   - showMode: Tip's show mode.
    public init(id: String? = nil, message: String, pointingMode: PointingMode, showMode: ShowMode) {
        self.id = id ?? message
        self.message = message
        self.pointingMode = pointingMode
        self.showMode = showMode
    }
}
