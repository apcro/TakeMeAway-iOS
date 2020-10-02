//
//  UILabel+CustomFontName.swift
//  TakeMeAway
//
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim

import Foundation
import UIKit

extension UIViewController {
    func setFontFamilyForView(_ fontFamily: String, view: UIView, andSubviews: Bool) {
        if let label = view as? UILabel {
            label.font = UIFont(name: fontFamily, size: label.font.pointSize)
        }
        
        if let textView = view as? UITextView {
            textView.font = UIFont(name: fontFamily, size: textView.font!.pointSize)
        }
        
        if let textField = view as? UITextField {
            textField.font = UIFont(name: fontFamily, size: textField.font!.pointSize)
        }
        
        if andSubviews {
            for v in view.subviews {
                setFontFamilyForView(fontFamily, view: v, andSubviews: true)
            }
        }
    }
}

