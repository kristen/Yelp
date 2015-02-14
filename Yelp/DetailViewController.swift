//
//  DetailViewController.swift
//  Yelp
//
//  Created by Kristen on 2/14/15.
//  Copyright (c) 2015 Kristen Sundquist. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var business: Business!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var numberOfReviewsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var reviewImageView: UIImageView!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        navigationItem.title = "Yelp"
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        updateUI()
    }

    func updateUI() {
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

        if let recomendedReviewImageUrl = business.recomendedReviewImageUrl {
            let url = NSURL(string: recomendedReviewImageUrl)
            thumbImageView.setImageWithURLRequest(NSMutableURLRequest(URL: url!), placeholderImage: nil, success: { (request, response, image) -> Void in
                self.reviewImageView.image = image
                if (request != nil && response != nil) {
                    self.reviewImageView.alpha = 0.0
                    UIView.animateWithDuration(1.0, animations: { () -> Void in
                        self.reviewImageView.alpha = 1.0
                    })
                }
                }, failure: nil)
        }
        if let recomendedReview = business.recomendedReviewText {
            reviewLabel.text = recomendedReview
        }
        if let displayPhone = business.displayPhone {
            phoneButton.setTitle(displayPhone, forState: UIControlState.Normal)
        }
    }

    
    @IBAction func touchedCallBusinessButton() {
        if let businessPhoneNumber = business.phoneNumber {
            if let url = NSURL(string: "tel://\(businessPhoneNumber)") {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
    }

}
