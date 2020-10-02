//
//  GradientView.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 24/02/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var topColor: UIColor = UIColor.clear {
        didSet {
            gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        }
    }
    @IBInspectable var bottomColor: UIColor = UIColor.clear {
        didSet {
            gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        }
    }
    
    var gradientLayer: CAGradientLayer!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        gradientLayer.frame = self.bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
