//
//  FiltersTableViewController.swift
//  Yelp
//
//  Created by Kristen on 2/12/15.
//  Copyright (c) 2015 Kristen Sundquist. All rights reserved.
//

import UIKit

protocol FiltersViewControllerDelegate : class {
    func filtersViewController(filtersViewController: FiltersTableViewController, didChangeFilters filters: [String: String])
}

class FiltersTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    @IBOutlet weak var filtersTableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    var categories: [[String:String]]!
    var filtersBySection: [(String, [String])]!
    let radius = ["40000", "200", "600", "1609", "8046"]
    var seeAllCategories = false
    let defaultCategoriesShown = 5
    
    enum Filters: Int {
        case MostPopular = 0, Distance, SortBy, Categories
    }
    
    var selectedFiltersIndex = [0,0,0]

    var selectedCategories = NSMutableSet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var defaults = NSUserDefaults.standardUserDefaults()
        selectedFiltersIndex[Filters.MostPopular.rawValue] = defaults.integerForKey("Filters_MostPopular")
        selectedFiltersIndex[Filters.Distance.rawValue] = defaults.integerForKey("Filters_Distance")
        selectedFiltersIndex[Filters.SortBy.rawValue] = defaults.integerForKey("Filters_SortBy")
        
        if let defaultCategories = defaults.arrayForKey("Filters_Categories") {
            selectedCategories = NSMutableSet(array: defaultCategories)
        }
        
        categories = getCategories()
        let categoryNames = categories.map { $0["name"]! }
        
        filtersBySection = [("Most Popular", ["Offering a Deal"]),
            ("Distance", ["Best Match", "2 blocks", "6 blocks", "1 mile", "5 miles"]),
            ("Sort by", ["Best Match", "Distance", "Raiting", "Most Reviewed"]),
            ("Categories", categoryNames)]

    
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
    
        filtersTableView.registerNib(UINib(nibName: "SwitchCell", bundle: nil), forCellReuseIdentifier: "SwitchCell")
        filtersTableView.registerNib(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "onCancelButton")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .Plain, target: self, action: "onApplyButton")
    
        navigationItem.title = "Filters"
        
        filtersTableView.reloadData()
    }

    func filters() -> [String: String] {
        var filters = [String : String]()
    
        var names = [String]()
        if selectedCategories.count > 0 {
            for category in selectedCategories {
                if let code = category["code"] as? String {
                    names.append(code)
                }
            }
        }

        let categoryFilter = NSArray(array: names).componentsJoinedByString(",")

        filters.updateValue(categoryFilter, forKey: "category_filter")
        
        let dealValue = selectedFiltersIndex[Filters.MostPopular.rawValue]
        filters.updateValue(["false", "true"][dealValue], forKey: "deals_filter")
        
        
        let radiusValue = selectedFiltersIndex[Filters.Distance.rawValue]
        filters.updateValue(radius[radiusValue], forKey: "radius_filter")
        
        let sortValue = selectedFiltersIndex[Filters.SortBy.rawValue]
        filters.updateValue(String(sortValue), forKey: "sort_filter")

        // save into nsuserdefaults
        
        var defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setInteger(dealValue, forKey: "Filters_MostPopular")
        defaults.setInteger(radiusValue, forKey: "Filters_Distance")
        defaults.setInteger(sortValue, forKey: "Filters_SortBy")
        defaults.setObject(selectedCategories.allObjects as NSArray, forKey: "Filters_Categories")
        
        defaults.synchronize()

        
        return filters
    }

    // MARK: - Table view data source
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return filtersBySection.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == Filters.Categories.rawValue && indexPath.row == defaultCategoriesShown - 1 && !seeAllCategories {
            seeAllCategories = true
        } else {
            selectedFiltersIndex[indexPath.section] = indexPath.row   
        }
        filtersTableView.reloadData()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Filters.Categories.rawValue where indexPath.row == defaultCategoriesShown - 1 && !seeAllCategories:
            let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell") as LabelCell

            cell.titleLabel.text = "Show All"
            
            return cell
        case Filters.MostPopular.rawValue, Filters.Categories.rawValue:
            
            var cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as SwitchCell
            cell.delegate = self
            cell.titleLabel.text = self.filtersBySection[indexPath.section].1[indexPath.row]
            
            if indexPath.section == Filters.MostPopular.rawValue {
                cell.toggleSwitch.on = selectedFiltersIndex[indexPath.row] == 1
            } else {
                cell.toggleSwitch.on = selectedCategories.containsObject(self.categories[indexPath.row])
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell") as LabelCell
            cell.titleLabel.text = self.filtersBySection[indexPath.section].1[indexPath.row]
            if (indexPath.row == selectedFiltersIndex[indexPath.section]) {
                cell.accessoryType = .Checkmark;
            } else {
                cell.accessoryType = .None;
            }
            return cell
        }
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Filters.Categories.rawValue && !seeAllCategories {
            return defaultCategoriesShown
        } else {
            return filtersBySection[section].1.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filtersBySection[section].0
    }
    
    func onCancelButton() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onApplyButton() {
        delegate?.filtersViewController(self, didChangeFilters: filters())
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func switchCell(switchCell: SwitchCell, didUpdateValue value: Bool) {
        if let indexPath = filtersTableView.indexPathForCell(switchCell) {
            if indexPath.section == Filters.Categories.rawValue {
                if value {
                    selectedCategories.addObject(categories[indexPath.row])
                } else {
                    selectedCategories.removeObject(categories[indexPath.row])
                }
            } else if indexPath.section == Filters.MostPopular.rawValue {
                selectedFiltersIndex[indexPath.section] = value ? 1 : 0
            }
        }   
    }
    
    func getCategories() -> [[String: String]] {
        // https://gist.github.com/wfalkwallace/6dd00fc2dae4c43103f6
        
        var categories: Array<[String:String]> = [
            ["name" : "American, Traditional", "code": "tradamerican" ],
            ["name" : "Pizza", "code": "pizza" ],
            ["name" : "Sushi Bars", "code": "sushi" ],
            ["name" : "Thai", "code": "thai" ],
            
            ["name" : "Afghan", "code": "afghani" ],
            ["name" : "African", "code": "african" ],
            ["name" : "Senegalese", "code": "senegalese" ],
            ["name" : "South African", "code": "southafrican" ],
            ["name" : "American, New", "code": "newamerican" ],
            ["name" : "Arabian", "code": "arabian" ],
            ["name" : "Argentine", "code": "argentine" ],
            ["name" : "Armenian", "code": "armenian" ],
            ["name" : "Asian Fusion", "code": "asianfusion" ],
            ["name" : "Australian", "code": "australian" ],
            ["name" : "Austrian", "code": "austrian" ],
            ["name" : "Bangladeshi", "code": "bangladeshi" ],
            ["name" : "Barbeque", "code": "bbq" ],
            ["name" : "Basque", "code": "basque" ],
            ["name" : "Belgian", "code": "belgian" ],
            ["name" : "Brasseries", "code": "brasseries" ],
            ["name" : "Brazilian", "code": "brazilian" ],
            ["name" : "Breakfast & Brunch", "code": "breakfast_brunch" ],
            ["name" : "British", "code": "british" ],
            ["name" : "Buffets", "code": "buffets" ],
            ["name" : "Burgers", "code": "burgers" ],
            ["name" : "Burmese", "code": "burmese" ],
            ["name" : "Cafes", "code": "cafes" ],
            ["name" : "Cafeteria", "code": "cafeteria" ],
            ["name" : "Cajun/Creole", "code": "cajun" ],
            ["name" : "Cambodian", "code": "cambodian" ],
            ["name" : "Caribbean", "code": "caribbean" ],
            ["name" : "Dominican", "code": "dominican" ],
            ["name" : "Haitian", "code": "haitian" ],
            ["name" : "Puerto Rican", "code": "puertorican" ],
            ["name" : "Trinidadian", "code": "trinidadian" ],
            ["name" : "Catalan", "code": "catalan" ],
            ["name" : "Cheesesteaks", "code": "cheesesteaks" ],
            ["name" : "Chicken Shop", "code": "chickenshop" ],
            ["name" : "Chicken Wings", "code": "chicken_wings" ],
            ["name" : "Chinese", "code": "chinese" ],
            ["name" : "Cantonese", "code": "cantonese" ],
            ["name" : "Dim Sum", "code": "dimsum" ],
            ["name" : "Shanghainese", "code": "shanghainese" ],
            ["name" : "Szechuan", "code": "szechuan" ],
            ["name" : "Comfort Food", "code": "comfortfood" ],
            ["name" : "Corsican", "code": "corsican" ],
            ["name" : "Creperies", "code": "creperies" ],
            ["name" : "Cuban", "code": "cuban" ],
            ["name" : "Czech", "code": "czech" ],
            ["name" : "Delis", "code": "delis" ],
            ["name" : "Diners", "code": "diners" ],
            ["name" : "Fast Food", "code": "hotdogs" ],
            ["name" : "Filipino", "code": "filipino" ],
            ["name" : "Fish & Chips", "code": "fishnchips" ],
            ["name" : "Fondue", "code": "fondue" ],
            ["name" : "Food Court", "code": "food_court" ],
            ["name" : "Food Stands", "code": "foodstands" ],
            ["name" : "French", "code": "french" ],
            ["name" : "Gastropubs", "code": "gastropubs" ],
            ["name" : "German", "code": "german" ],
            ["name" : "Gluten-Free", "code": "gluten_free" ],
            ["name" : "Greek", "code": "greek" ],
            ["name" : "Halal", "code": "halal" ],
            ["name" : "Hawaiian", "code": "hawaiian" ],
            ["name" : "Himalayan/Nepalese", "code": "himalayan" ],
            ["name" : "Hong Kong Style Cafe", "code": "hkcafe" ],
            ["name" : "Hot Dogs", "code": "hotdog" ],
            ["name" : "Hot Pot", "code": "hotpot" ],
            ["name" : "Hungarian", "code": "hungarian" ],
            ["name" : "Iberian", "code": "iberian" ],
            ["name" : "Indian", "code": "indpak" ],
            ["name" : "Indonesian", "code": "indonesian" ],
            ["name" : "Irish", "code": "irish" ],
            ["name" : "Italian", "code": "italian" ],
            ["name" : "Japanese", "code": "japanese" ],
            ["name" : "Ramen", "code": "ramen" ],
            ["name" : "Teppanyaki", "code": "teppanyaki" ],
            ["name" : "Korean", "code": "korean" ],
            ["name" : "Kosher", "code": "kosher" ],
            ["name" : "Laotian", "code": "laotian" ],
            ["name" : "Latin American", "code": "latin" ],
            ["name" : "Colombian", "code": "colombian" ],
            ["name" : "Salvadorean", "code": "salvadorean" ],
            ["name" : "Venezuelan", "code": "venezuelan" ],
            ["name" : "Live/Raw Food", "code": "raw_food" ],
            ["name" : "Malaysian", "code": "malaysian" ],
            ["name" : "Mediterranean", "code": "mediterranean" ],
            ["name" : "Falafel", "code": "falafel" ],
            ["name" : "Mexican", "code": "mexican" ],
            ["name" : "Middle Eastern", "code": "mideastern" ],
            ["name" : "Egyptian", "code": "egyptian" ],
            ["name" : "Lebanese", "code": "lebanese" ],
            ["name" : "Modern European", "code": "modern_european" ],
            ["name" : "Mongolian", "code": "mongolian" ],
            ["name" : "Moroccan", "code": "moroccan" ],
            ["name" : "Pakistani", "code": "pakistani" ],
            ["name" : "Persian/Iranian", "code": "persian" ],
            ["name" : "Peruvian", "code": "peruvian" ],
            ["name" : "Polish", "code": "polish" ],
            ["name" : "Portuguese", "code": "portuguese" ],
            ["name" : "Poutineries", "code": "poutineries" ],
            ["name" : "Russian", "code": "russian" ],
            ["name" : "Salad", "code": "salad" ],
            ["name" : "Sandwiches", "code": "sandwiches" ],
            ["name" : "Scandinavian", "code": "scandinavian" ],
            ["name" : "Scottish", "code": "scottish" ],
            ["name" : "Seafood", "code": "seafood" ],
            ["name" : "Singaporean", "code": "singaporean" ],
            ["name" : "Slovakian", "code": "slovakian" ],
            ["name" : "Soul Food", "code": "soulfood" ],
            ["name" : "Soup", "code": "soup" ],
            ["name" : "Southern", "code": "southern" ],
            ["name" : "Spanish", "code": "spanish" ],
            ["name" : "Sri Lankan", "code": "srilankan" ],
            ["name" : "Steakhouses", "code": "steak" ],
            ["name" : "Taiwanese", "code": "taiwanese" ],
            ["name" : "Tapas Bars", "code": "tapas" ],
            ["name" : "Tapas/Small Plates", "code": "tapasmallplates" ],
            ["name" : "Tex-Mex", "code": "tex-mex" ],
            ["name" : "Turkish", "code": "turkish" ],
            ["name" : "Ukrainian", "code": "ukrainian" ],
            ["name" : "Uzbek", "code": "uzbek" ],
            ["name" : "Vegan", "code": "vegan" ],
            ["name" : "Vegetarian", "code": "vegetarian" ],
            ["name" : "Vietnamese", "code": "vietnamese" ]]
            return categories

    }
}
