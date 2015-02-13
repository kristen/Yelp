//
//  ViewController.swift
//  Yelp
//
//  Created by Kristen on 2/8/15.
//  Copyright (c) 2015 Kristen Sundquist. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    var client: YelpClient!
    
    @IBOutlet weak var businessTableView: UITableView!
    let yelpConsumerKey = "kRyJ7J0tzSytiDxknPNS3Q"
    let yelpConsumerSecret = "9ghoeZyZXYUR0GDnHnEdfqoqLkk"
    let yelpToken = "Gdz-5v2nxZYXLhWYT5sKUmHYj3Lr3sg8"
    let yelpTokenSecret = "BxxPae9UJmonyoNUXqtKx0PlgQk"
    var businesses = [Business]()
    var filteredBusinessess = [Business]()
    var searchController: UISearchController!
    var isFiltered = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        businessTableView.dataSource = self
        businessTableView.delegate = self
        businessTableView.registerNib(UINib(nibName: "BusinessCell", bundle: nil), forCellReuseIdentifier: "BusinessCell")
        businessTableView.estimatedRowHeight = 90
        businessTableView.rowHeight = UITableViewAutomaticDimension
        navigationItem.title = "Yelp"
        
        // Search Controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        businessTableView.tableHeaderView = searchController.searchBar
        
        definesPresentationContext = true
        
        client = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        client.searchWithTerm("Thai", success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let json = JSON(response)
            
            if let businessessArray = json["businesses"].array {
                self.businesses = Business.businessWithDictionaries(businessessArray)
            } else { // TODO: maybe don't clear out data when request doesn't work?
                self.businesses = []
            }
            
            self.businessTableView.reloadData()
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error.description)
        }
    }
    
    //MARK - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltered {
            return filteredBusinessess.count
        } else {
            return self.businesses.count
        }
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell") as BusinessCell
        
        var business: Business
        if isFiltered {
            business = self.filteredBusinessess[indexPath.row]
        } else {
            business = self.businesses[indexPath.row]
        }
        
        cell.setBusiness(business, forIndex: indexPath.row)
        
        return cell
        
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        
        if (searchText as NSString).length == 0 {
            isFiltered = false
        } else {
            isFiltered = true
            filteredBusinessess = businesses.filter {( business: Business) -> Bool in
                return business.name.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            }
        }
        
        businessTableView.reloadData()
    }
}

