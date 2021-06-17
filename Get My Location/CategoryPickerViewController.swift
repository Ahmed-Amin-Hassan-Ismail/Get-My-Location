//
//  CategoryPickerViewController.swift
//  Get My Location
//
//  Created by Amin  on 6/17/21.
//  Copyright © 2021 AhmedAmin. All rights reserved.
//

import UIKit

// Delegate Pattern
protocol CategoryPickerViewControllerDelegate: class {
    
    func CategoryPickerViewController(controller: CategoryPickerViewController, didPicked category: String)
}

class CategoryPickerViewController: UITableViewController {
    
    let categories = [
        "No Category",
        "Apple Store",
        "Bar",
        "Bookstore",
        "Club",
        "Grocery Store",
        "Historic Building",
        "House",
        "Ice cream Vendor",
        "Landmark",
        "Park"
    ]
    var selectedCategoryName = " "
    var selectedIndex = IndexPath()
    
    weak var delegate: CategoryPickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide empty cells
        tableView.tableFooterView = UIView()
        
        for i in 0..<categories.count {
            if categories[i] == selectedCategoryName {
                selectedIndex = IndexPath(row: i, section: 0)
                break
            }
        }
        
    }
    
}

// MARK: - TableView DataSource

extension CategoryPickerViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "categoryCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // configure cell...
        let category = categories[indexPath.row]
        cell.textLabel?.text = category
        cell.accessoryType =
            (category == selectedCategoryName ? .checkmark : .none)
        
        
        return cell
    }
}


// MARK: - TableView Delegate

extension CategoryPickerViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row != selectedIndex.row {
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
            }
            if let oldCell = tableView.cellForRow(at: selectedIndex) {
                oldCell.accessoryType = .none
            }
            selectedIndex = indexPath
        }
        // Invoke Delegate
        let selectedCategory = categories[indexPath.row]
        delegate?.CategoryPickerViewController(controller: self, didPicked: selectedCategory)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
