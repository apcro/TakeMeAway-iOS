//
//  DestinationCardView.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 04/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahimw
//

import UIKit

class DestinationCardView: UIView {
        
    @IBOutlet weak var planeIconView: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var hotelPrice: UILabel!
    @IBOutlet weak var hotelIconView: UIImageView!
    @IBOutlet weak var weathericon: UILabel!
    @IBOutlet weak var weatherdescription: UILabel!
    @IBOutlet weak var saveIcon: UIImageView!
    
    let CORNER_RAD: CGFloat = 10.0
    
    override init(frame: CGRect) {  // for using view in code
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {  // for using in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("DestinationCardView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.clipsToBounds = true
        self.layer.cornerRadius = CORNER_RAD
        
        // tint view again because xcode is a piece of shit and ignores
        // my tinting if a view doesn't have a certain configuration
        // of spacing constraints... >:(
        planeIconView.tintColor = UIColor.TMAColors.LightTeal
        hotelIconView.tintColor = UIColor.TMAColors.LightTeal
    }

}
