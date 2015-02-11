//
//  BusinessCell.swift
//  Yelp
//
//  Created by Kristen on 2/10/15.
//  Copyright (c) 2015 Kristen Sundquist. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {
    
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var numberOfReviewsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
        thumbImageView.layer.cornerRadius = 3
        thumbImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setBusiness(business: Business) {
        if let imageURL = business.imageURL {
            let url = NSURL(string: imageURL)
            thumbImageView.setImageWithURLRequest(NSMutableURLRequest(URL: url!), placeholderImage: nil, success: { (request, response, image) -> Void in
                self.thumbImageView.image = image
                if (request != nil && response != nil) {
                    self.thumbImageView.alpha = 0.0
                    UIView.animateWithDuration(1.0, animations: { () -> Void in
                        self.thumbImageView.alpha = 1.0
                    })
                }
                }, failure: nil)
        }
        
        nameLabel.text = business.name
        let distance = NSString(format: "%.2f", business.distance)
        distanceLabel.text = "\(distance) mi"
        if let ratingImageURL = business.ratingImageUrl {
            ratingImageView.setImageWithURL(NSURL(string: ratingImageURL))
        }
        numberOfReviewsLabel.text = "\(business.numberOfReviews) Reviews"
        addressLabel.text = business.address
        categoryLabel.text = business.categories
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width

    }
    
}
