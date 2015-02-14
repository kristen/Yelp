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
    
    enum Filters: Int {
        case MostPopular = 0, Distance, SortBy, Categories
    }
    
    var selectedFiltersIndex = [0,0,0,0]

    var selectedCategories = NSMutableSet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        
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
        
        filters.updateValue(["false", "true"][selectedFiltersIndex[Filters.MostPopular.rawValue]], forKey: "deals_filter")
        
        let radius = ["40000", "200", "600", "1609", "8046"]
        
        filters.updateValue(radius[selectedFiltersIndex[Filters.Distance.rawValue]], forKey: "radius_filter")
        
        filters.updateValue(String(selectedFiltersIndex[Filters.SortBy.rawValue]), forKey: "sort_filter")

        return filters
    }

    // MARK: - Table view data source
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return filtersBySection.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedFiltersIndex[indexPath.section] = indexPath.row
        filtersTableView.reloadData()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Filters.MostPopular.rawValue, Filters.Categories.rawValue:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as SwitchCell
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
        return filtersBySection[section].1.count
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
        var categories = [
            ["name" : "American, New", "code": "newamerican"],
            ["name" : "Barbeque", "code": "bbq"],
            ["name" : "Mexican", "code": "mexican"],
            ["name" : "Sushi Bars", "code": "sushi"]
        ]
        
//        var categories = [["name" : "Afghan", "code": "afghani"]]
//        categories.append(["name" : "African", "code": "african"])
//        categories.append(["name" : "American, New", "code": "newamerican"])
//        categories.append(["name" : "American, Traditional", "code": "tradamerican"])
//        categories.append(["name" : "Arabian", "code": "arabian"])
//        categories.append(["name" : "Argentine", "code": "argentine"])
//        categories.append(["name" : "Armenian", "code": "armenian"])
//        categories.append(["name" : "Asian Fusion", "code": "asianfusion"])
//        categories.append(["name" : "Asturian", "code": "asturian"])
//        categories.append(["name" : "Australian", "code": "australian"])
//        categories.append(["name" : "Austrian", "code": "austrian"])
//        categories.append(["name" : "Baguettes", "code": "baguettes"])
//        categories.append(["name" : "Bangladeshi", "code": "bangladeshi"])
//        categories.append(["name" : "Barbeque", "code": "bbq"])
//        categories.append(["name" : "Basque", "code": "basque"])
//        categories.append(["name" : "Bavarian", "code": "bavarian"])
//        categories.append(["name" : "Beer Garden", "code": "beergarden"])
//        categories.append(["name" : "Beer Hall", "code": "beerhall"])
//        categories.append(["name" : "Beisl", "code": "beisl"])
//        categories.append(["name" : "Belgian", "code": "belgian"])
//        categories.append(["name" : "Bistros", "code": "bistros"])
//        categories.append(["name" : "Black Sea", "code": "blacksea"])
//        categories.append(["name" : "Brasseries", "code": "brasseries"])
//        categories.append(["name" : "Brazilian", "code": "brazilian"])
//        categories.append(["name" : "Breakfast & Brunch", "code": "breakfast_brunch"])
//        categories.append(["name" : "British", "code": "british"])
//        categories.append(["name" : "Buffets", "code": "buffets"])
//        categories.append(["name" : "Bulgarian", "code": "bulgarian"])
//        categories.append(["name" : "Burgers", "code": "burgers"])
//        categories.append(["name" : "Burmese", "code": "burmese"])
//        categories.append(["name" : "Cafes", "code": "cafes"])
//        categories.append(["name" : "Cafeteria", "code": "cafeteria"])
//        categories.append(["name" : "Cajun/Creole", "code": "cajun"])
//        categories.append(["name" : "Cambodian", "code": "cambodian"])
//        categories.append(["name" : "Canadian", "code": "New)"])
//        categories.append(["name" : "Canteen", "code": "canteen"])
//        categories.append(["name" : "Caribbean", "code": "caribbean"])
//        categories.append(["name" : "Catalan", "code": "catalan"])
//        categories.append(["name" : "Chech", "code": "chech"])
//        categories.append(["name" : "Cheesesteaks", "code": "cheesesteaks"])
//        categories.append(["name" : "Chicken Shop", "code": "chickenshop"])
//        categories.append(["name" : "Chicken Wings", "code": "chicken_wings"])
//        categories.append(["name" : "Chilean", "code": "chilean"])
//        categories.append(["name" : "Chinese", "code": "chinese"])
//        categories.append(["name" : "Comfort Food", "code": "comfortfood"])
//        categories.append(["name" : "Corsican", "code": "corsican"])
//        categories.append(["name" : "Creperies", "code": "creperies"])
//        categories.append(["name" : "Cuban", "code": "cuban"])
//        categories.append(["name" : "Curry Sausage", "code": "currysausage"])
//        categories.append(["name" : "Cypriot", "code": "cypriot"])
//        categories.append(["name" : "Czech", "code": "czech"])
//        categories.append(["name" : "Czech/Slovakian", "code": "czechslovakian"])
//        categories.append(["name" : "Danish", "code": "danish"])
//        categories.append(["name" : "Delis", "code": "delis"])
//        categories.append(["name" : "Diners", "code": "diners"])
//        categories.append(["name" : "Dumplings", "code": "dumplings"])
//        categories.append(["name" : "Eastern European", "code": "eastern_european"])
//        categories.append(["name" : "Ethiopian", "code": "ethiopian"])
//        categories.append(["name" : "Fast Food", "code": "hotdogs"])
//        categories.append(["name" : "Filipino", "code": "filipino"])
//        categories.append(["name" : "Fish & Chips", "code": "fishnchips"])
//        categories.append(["name" : "Fondue", "code": "fondue"])
//        categories.append(["name" : "Food Court", "code": "food_court"])
//        categories.append(["name" : "Food Stands", "code": "foodstands"])
//        categories.append(["name" : "French", "code": "french"])
//        categories.append(["name" : "French Southwest", "code": "sud_ouest"])
//        categories.append(["name" : "Galician", "code": "galician"])
//        categories.append(["name" : "Gastropubs", "code": "gastropubs"])
//        categories.append(["name" : "Georgian", "code": "georgian"])
//        categories.append(["name" : "German", "code": "german"])
//        categories.append(["name" : "Giblets", "code": "giblets"])
//        categories.append(["name" : "Gluten-Free", "code": "gluten_free"])
//        categories.append(["name" : "Greek", "code": "greek"])
//        categories.append(["name" : "Halal", "code": "halal"])
//        categories.append(["name" : "Hawaiian", "code": "hawaiian"])
//        categories.append(["name" : "Heuriger", "code": "heuriger"])
//        categories.append(["name" : "Himalayan/Nepalese", "code": "himalayan"])
//        categories.append(["name" : "Hong Kong Style Cafe", "code": "hkcafe"])
//        categories.append(["name" : "Hot Dogs", "code": "hotdog"])
//        categories.append(["name" : "Hot Pot", "code": "hotpot"])
//        categories.append(["name" : "Hungarian", "code": "hungarian"])
//        categories.append(["name" : "Iberian", "code": "iberian"])
//        categories.append(["name" : "Indian", "code": "indpak"])
//        categories.append(["name" : "Indonesian", "code": "indonesian"])
//        categories.append(["name" : "International", "code": "international"])
//        categories.append(["name" : "Irish", "code": "irish"])
//        categories.append(["name" : "Island Pub", "code": "island_pub"])
//        categories.append(["name" : "Israeli", "code": "israeli"])
//        categories.append(["name" : "Italian", "code": "italian"])
//        categories.append(["name" : "Japanese", "code": "japanese"])
//        categories.append(["name" : "Jewish", "code": "jewish"])
//        categories.append(["name" : "Kebab", "code": "kebab"])
//        categories.append(["name" : "Korean", "code": "korean"])
//        categories.append(["name" : "Kosher", "code": "kosher"])
//        categories.append(["name" : "Kurdish", "code": "kurdish"])
//        categories.append(["name" : "Laos", "code": "laos"])
//        categories.append(["name" : "Laotian", "code": "laotian"])
//        categories.append(["name" : "Latin American", "code": "latin"])
//        categories.append(["name" : "Live/Raw Food", "code": "raw_food"])
//        categories.append(["name" : "Lyonnais", "code": "lyonnais"])
//        categories.append(["name" : "Malaysian", "code": "malaysian"])
//        categories.append(["name" : "Meatballs", "code": "meatballs"])
//        categories.append(["name" : "Mediterranean", "code": "mediterranean"])
//        categories.append(["name" : "Mexican", "code": "mexican"])
//        categories.append(["name" : "Middle Eastern", "code": "mideastern"])
//        categories.append(["name" : "Milk Bars", "code": "milkbars"])
//        categories.append(["name" : "Modern Australian", "code": "modern_australian"])
//        categories.append(["name" : "Modern European", "code": "modern_european"])
//        categories.append(["name" : "Mongolian", "code": "mongolian"])
//        categories.append(["name" : "Moroccan", "code": "moroccan"])
//        categories.append(["name" : "New Zealand", "code": "newzealand"])
//        categories.append(["name" : "Night Food", "code": "nightfood"])
//        categories.append(["name" : "Norcinerie", "code": "norcinerie"])
//        categories.append(["name" : "Open Sandwiches", "code": "opensandwiches"])
//        categories.append(["name" : "Oriental", "code": "oriental"])
//        categories.append(["name" : "Pakistani", "code": "pakistani"])
//        categories.append(["name" : "Parent Cafes", "code": "eltern_cafes"])
//        categories.append(["name" : "Parma", "code": "parma"])
//        categories.append(["name" : "Persian/Iranian", "code": "persian"])
//        categories.append(["name" : "Peruvian", "code": "peruvian"])
//        categories.append(["name" : "Pita", "code": "pita"])
//        categories.append(["name" : "Pizza", "code": "pizza"])
//        categories.append(["name" : "Polish", "code": "polish"])
//        categories.append(["name" : "Portuguese", "code": "portuguese"])
//        categories.append(["name" : "Potatoes", "code": "potatoes"])
//        categories.append(["name" : "Poutineries", "code": "poutineries"])
//        categories.append(["name" : "Pub Food", "code": "pubfood"])
//        categories.append(["name" : "Rice", "code": "riceshop"])
//        categories.append(["name" : "Romanian", "code": "romanian"])
//        categories.append(["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"])
//        categories.append(["name" : "Rumanian", "code": "rumanian"])
//        categories.append(["name" : "Russian", "code": "russian"])
//        categories.append(["name" : "Salad", "code": "salad"])
//        categories.append(["name" : "Sandwiches", "code": "sandwiches"])
//        categories.append(["name" : "Scandinavian", "code": "scandinavian"])
//        categories.append(["name" : "Scottish", "code": "scottish"])
//        categories.append(["name" : "Seafood", "code": "seafood"])
//        categories.append(["name" : "Serbo Croatian", "code": "serbocroatian"])
//        categories.append(["name" : "Signature Cuisine", "code": "signature_cuisine"])
//        categories.append(["name" : "Singaporean", "code": "singaporean"])
//        categories.append(["name" : "Slovakian", "code": "slovakian"])
//        categories.append(["name" : "Soul Food", "code": "soulfood"])
//        categories.append(["name" : "Soup", "code": "soup"])
//        categories.append(["name" : "Southern", "code": "southern"])
//        categories.append(["name" : "Spanish", "code": "spanish"])
//        categories.append(["name" : "Steakhouses", "code": "steak"])
//        categories.append(["name" : "Sushi Bars", "code": "sushi"])
//        categories.append(["name" : "Swabian", "code": "swabian"])
//        categories.append(["name" : "Swedish", "code": "swedish"])
//        categories.append(["name" : "Swiss Food", "code": "swissfood"])
//        categories.append(["name" : "Tabernas", "code": "tabernas"])
//        categories.append(["name" : "Taiwanese", "code": "taiwanese"])
//        categories.append(["name" : "Tapas Bars", "code": "tapas"])
//        categories.append(["name" : "Tapas/Small Plates", "code": "tapasmallplates"])
//        categories.append(["name" : "Tex-Mex", "code": "tex-mex"])
//        categories.append(["name" : "Thai", "code": "thai"])
//        categories.append(["name" : "Traditional Norwegian", "code": "norwegian"])
//        categories.append(["name" : "Traditional Swedish", "code": "traditional_swedish"])
//        categories.append(["name" : "Trattorie", "code": "trattorie"])
//        categories.append(["name" : "Turkish", "code": "turkish"])
//        categories.append(["name" : "Ukrainian", "code": "ukrainian"])
//        categories.append(["name" : "Uzbek", "code": "uzbek"])
//        categories.append(["name" : "Vegan", "code": "vegan"])
//        categories.append(["name" : "Vegetarian", "code": "vegetarian"])
//        categories.append(["name" : "Venison", "code": "venison"])
//        categories.append(["name" : "Vietnamese", "code": "vietnamese"])
//        categories.append(["name" : "Wok", "code": "wok"])
//        categories.append(["name" : "Wraps", "code": "wraps"])
//        categories.append(["name" : "Yugoslav", "code": "yugoslav"])
        return categories

    }
}
