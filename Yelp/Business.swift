//
//  Business.swift
//  Yelp
//
//  Created by Kristen on 2/9/15.
//  Copyright (c) 2015 Kristen Sundquist. All rights reserved.
//
import MapKit

class Business : NSObject, MKAnnotation {
    
    let categories: String
    let name: String
    let address: String
    let latitude: Double?
    let longitude: Double?
    let numberOfReviews: Int
    let imageURL: String?
    let ratingImageUrl: String?
    let distance: Double
    let displayPhone: String?
    let phoneNumber: Int?
    let recomendedReviewImageUrl: String?
    let recomendedReviewText: String?
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        }
    }

    var title: String {
        get {
            return name
        }
    }
    
    init(json: JSON) {
        var categoryNames = [String]()
        
        if let categoryArray = json["categories"].array {
            categoryNames = categoryArray.map { array in
                if let category = array[0].string {
                    return category
                }
                return ""
            }
        }
                
        self.categories = ", ".join(categoryNames)
        
        if let name = json["name"].string {
            self.name = name
        } else {
            self.name = ""
        }
        
        if let imageURL = json["image_url"].string {
            self.imageURL = imageURL
        }
        
        if let street = json["location"]["address"][0].string {
            if let neighborhood = json["location"]["neighborhoods"][0].string {
                self.address = "\(street), \(neighborhood)"
            } else {
                self.address = street
            }
        } else {
            self.address = ""
        }
        
        if let latitude = json["location"]["coordinate"]["latitude"].number {
            self.latitude = latitude.doubleValue
        }
        if let longitude = json["location"]["coordinate"]["longitude"].number {
            self.longitude = longitude.doubleValue
        }
        
        if let numberOfReviews = json["review_count"].int {
            self.numberOfReviews = numberOfReviews
        } else {
            self.numberOfReviews = 0
        }
        
        if let ratingImageUrl = json["rating_img_url"].string {
            self.ratingImageUrl = ratingImageUrl
        }
        
        let milesPerMeter = 0.0006213171
        if let distance = json["distance"].int {
            self.distance = Double(distance) * milesPerMeter
        } else {
            self.distance = 0
        }
        
        if let displayPhone = json["display_phone"].string {
            self.displayPhone = displayPhone
        }
        
        // http://stackoverflow.com/questions/25117321/iphone-call-from-app-in-swift-xcode-6
        if let phoneNumber = json["phone_number"].int {
            self.phoneNumber = phoneNumber
        }
        
        if let recomendedReviewImageUrl = json["snippet_image_url"].string {
            self.recomendedReviewImageUrl = recomendedReviewImageUrl
        }
        
        if let recomendedReviewText = json["snippet_text"].string {
            self.recomendedReviewText = recomendedReviewText
        }
    }
    
    class func businessWithDictionaries(jsonArray: [JSON]) -> [Business] {
        return jsonArray.map { Business(json: $0) }
    }
}