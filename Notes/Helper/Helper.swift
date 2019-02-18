//
//  Segues.swift
//  Notes
//
//  Created by Nguyen Lam on 2/13/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation

public let NOTI_DASHLINE_COLOR_CHANGED = "DASH_LINE_COLOR_CHANGE"

public func customDateFormatter() -> DateFormatter {

    let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, HH:mm"
    
    return dateFormatter
}
