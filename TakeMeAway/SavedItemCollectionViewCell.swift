//
//  SavedItemCollectionViewCell.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 18/02/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit

class SavedItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cityImageView: UIImageView!
    @IBOutlet weak var hotelImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var hotelLabel: UILabel!
    
    @IBOutlet weak var savedOn: UILabel!
    @IBOutlet weak var flightPrice: UILabel!
    @IBOutlet weak var hotelPrice: UILabel!
    
    @IBOutlet weak var ratingBox: UIView!
    @IBOutlet weak var ratingValue: UILabel!
    
    
    @IBOutlet weak var hotelGradient: GradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
