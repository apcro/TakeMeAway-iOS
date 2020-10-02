//
//  HotelCarouselCardView.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 04/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit

class HotelCarouselCardView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var perNightPriceLabel: UILabel!
    @IBOutlet weak var ribbonView: CornerRibbonLabelView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var ratingBox: UIView!
    @IBOutlet weak var ratingValue: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    override init(frame: CGRect) {  // for using view in code
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {  // for using in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("HotelCarouselCardView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        ratingLabel.font = UIFont(name: "Muli", size: 18);
        perNightPriceLabel.font = UIFont(name: "Muli", size: 18);
        
    

        
    }
        


}
