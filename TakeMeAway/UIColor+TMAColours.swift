//
//  UIColor+TMAColours.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 03/02/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    struct TMAColors {
        static let DarkTeal = UIColor(red: 2, green: 72, blue: 96)
        static let LightTeal = UIColor(red: 116, green: 204, blue: 208)
        static let Gold = UIColor(red: 253, green: 184, blue: 52)
        static let DarkGrey = UIColor(red: 101, green: 101, blue: 101)
        static let LightGrey = UIColor(red: 219, green: 219, blue: 219)
        static let Red = UIColor(red: 180, green: 0, blue: 15)
    }
}
