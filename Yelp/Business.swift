//
//  Business.swift
//  Yelp
//
//  Created by Kristen on 2/9/15.
//  Copyright (c) 2015 Kristen Sundquist. All rights reserved.
//


class Business : NSObject {
    
    let categories: String
    let name: String
    let address: String
    let numberOfReviews: Int
    let imageURL: String?
    let ratingImageUrl: String?
    let distance: Double
    
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
        } else {
            self.imageURL = nil
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
        
        if let numberOfReviews = json["review_count"].int {
            self.numberOfReviews = numberOfReviews
        } else {
            self.numberOfReviews = 0
        }
        
        if let ratingImageUrl = json["rating_img_url"].string {
            self.ratingImageUrl = ratingImageUrl
        } else {
            self.ratingImageUrl = nil
        }
        
        let milesPerMeter = 0.0006213171
        if let distance = json["distance"].int {
            self.distance = Double(distance) * milesPerMeter
        } else {
            self.distance = 0
        }
    }
    
    class func businessWithDictionaries(jsonArray: [JSON]) -> [Business] {
        return jsonArray.map { Business(json: $0) }
    }
}