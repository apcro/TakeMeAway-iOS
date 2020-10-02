//
//  ProfileFormHeaderView.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 28/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit

class ProfileFormHeaderView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("ProfileFormHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        imageView.layer.cornerRadius = imageView.frame.height / 2.0
        imageView.layer.borderWidth = 3.0
        imageView.layer.borderColor = UIColor.TMAColors.DarkTeal.cgColor
    }
    
    // adjust border radius of image view when bounds change
    override func layoutSubviews() {
        imageView.layoutIfNeeded()
        imageView.layer.cornerRadius = imageView.frame.height / 2.0
    }

}
