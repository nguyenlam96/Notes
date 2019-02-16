//
//  Note.swift
//  Notes
//
//  Created by Nguyen Lam on 2/13/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation

extension Note {
    
    // MARK: - Exchange Date and NSDate :
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
    
    // MARK: - Tags :
    var alphabetizedTags: [Tag]? {
        
        guard let tags = self.tags as? Set<Tag> else {
            LogUtils.LogDebug(type: .warning, message: "Fail to get tags")
            return nil
        }
        let sortedTags = tags.sorted {
            guard let tag0Name = $0.name else { return true }
            guard let tag1Name = $1.name else { return true }
            return tag0Name < tag1Name
        }
        return sortedTags
    }
    
    var alphabetizedTagsAsString: String? {
        
        guard let tags = alphabetizedTags, tags.count > 0 else {
//            LogUtils.LogDebug(type: .warning, message: "tags is nil or empty")
            return nil
        }
        let tagNameArray = tags.compactMap { $0.name }
        return tagNameArray.joined(separator: ", ")
    }
}
