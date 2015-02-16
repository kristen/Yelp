//
//  DetailViewController.swift
//  Yelp
//
//  Created by Kristen on 2/14/15.
//  Copyright (c) 2015 Kristen Sundquist. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, MKMapViewDelegate {

    var business: Business!
    @IBOutlet private weak var thumbImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var ratingImageView: UIImageView!
    @IBOutlet private weak var numberOfReviewsLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var reviewImageView: UIImageView!
    @IBOutlet private weak var reviewLabel: UILabel!
    @IBOutlet private weak var phoneButton: UIButton!
    @IBOutlet private weak var businessMapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        businessMapView.delegate = self
        navigationItem.title = "Yelp"
        
        reviewImageView.layer.cornerRadius = 3
        reviewImageView.clipsToBounds = true
        updateMapViewAnnotation()
        updateUI()
    }

    private func updateUI() {
        thumbImageView.contentMode = UIViewContentMode.ScaleAspectFill
        thumbImageView.clipsToBounds = true
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
        ratingImageView.contentMode = .ScaleAspectFit
        if let ratingImageURL = business.ratingImageUrl {
            ratingImageView.setImageWithURL(NSURL(string: ratingImageURL))
        }
        numberOfReviewsLabel.text = "\(business.numberOfReviews) Reviews"
        addressLabel.text = business.displayAddress
        categoryLabel.text = business.categories

        reviewImageView.contentMode = UIViewContentMode.ScaleAspectFit
        if let recomendedReviewImageUrl = business.recomendedReviewImageUrl {
            let url = NSURL(string: recomendedReviewImageUrl)
            reviewImageView.setImageWithURLRequest(NSMutableURLRequest(URL: url!), placeholderImage: nil, success: { (request, response, image) -> Void in
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
    
    private func updateMapViewAnnotation() {
        businessMapView.removeAnnotations(businessMapView.annotations)
        businessMapView.addAnnotation(business)
        businessMapView.showAnnotations([business], animated: true)
    }
}
