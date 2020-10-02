//
//  CornerRibbonLabelView.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 04/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit

class CornerRibbonLabelView: UIView {
    
    var labelText: String! = "SOMETHING!" {
        didSet {
            labelView.text = labelText
        }
    }
    var ribbonColour: UIColor = .red {
        didSet {
            labelView.backgroundColor = ribbonColour
        }
    }
    
    private let labelView = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        labelView.text = labelText
        labelView.backgroundColor = ribbonColour
        labelView.textColor = UIColor.TMAColors.LightTeal
        labelView.textAlignment = .center
        addSubview(labelView)
        
        let frame = CGRect(x:0.0, y:0.0, width:bounds.width * 2, height:25.0)
        labelView.frame = frame
        
        // spin label around
        let transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 4)
        labelView.transform = transform
        labelView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // something funny going on trying to position after applying transform...
        // not causing issues for now, but may have to fix later
//        labelView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }

}
