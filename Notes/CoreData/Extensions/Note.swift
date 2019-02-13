//
//  Note.swift
//  Notes
//
//  Created by Nguyen Lam on 2/13/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation

extension Note {
    
    var updatedAtAsDate: Date {
        guard let updatedAt = self.updatedAt else {
            LogUtils.LogDebug(type: .warning, message: "updatedAt is nil")
            return Date()
        }
        return Date(timeIntervalSince1970: updatedAt.timeIntervalSince1970)
        
    }
    
    var createdAtAsDate: Date {
        guard let createddAt = self.updatedAt else {
            LogUtils.LogDebug(type: .warning, message: "createddAt is nil")
            return Date()
        }
        return Date(timeIntervalSince1970: createddAt.timeIntervalSince1970)
    }
    
}
