//
//  Category+.swift
//  Notes
//
//  Created by Nguyen Lam on 2/14/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

extension Category {
    
    // declare computed 'color' property for Category object to convenience to exchange between UIColor and HexString ( remember that in the database the color is still saved as hexString)
    var color: UIColor? {
        
        get {
            guard let hex: String = self.colorAsHex else {
                LogUtils.LogDebug(type: .error, message: "Can't get colorAsHex")
                return nil
            }
            return UIColor(hex: hex)
        }
        set(newColor) {
            if let newColor: UIColor = newColor {
                self.colorAsHex = newColor.toHex
            }
        }
    }
}
