//
//  LocationDetailsViewController.swift
//  Get My Location
//
//  Created by Amin  on 6/17/21.
//  Copyright © 2021 AhmedAmin. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    
    // Core Data Instance
    var managedObjectContext: NSManagedObjectContext!
    
    //Instance Variables
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var date = Date()
    var categoryName = "No Category"
    var descriptionName = ""
    
    // For editing
    var locationToEdit: Location? {
        didSet {
            // Display Edit Location
            if let locationToEdit = locationToEdit {
                title = "Edit Location"
                
                descriptionName = locationToEdit.locationDescription
                categoryName = locationToEdit.category
                coordinate = CLLocationCoordinate2DMake(locationToEdit.latitude, locationToEdit.longitude)
                placemark = locationToEdit.placemark
                date = locationToEdit.date
                
            }
        }
        
    }
    
    // Outlets
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel! {
        didSet {
            addressLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var dateLabel: UILabel!
    
    
    // Actions
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        let location: Location
        
        if let temporaryLocation = locationToEdit {
            hudView.text = "Updated"
            location = temporaryLocation
        } else {
            hudView.text = "Tagged"
            // Saving Into Core Data
            location = Location(context: managedObjectContext)
        }
        saveIntoCoreData(for: location)
        // Grand Central Dispatch
        afterDelay(0.6) { [unowned self ] in
            hudView.hideHUD()
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    // MARK: - VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide empty cells
        tableView.tableFooterView = UIView()
        
        // pass data
        displayLabels()
        
        // Deactive the keyboard
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func hideKeyboard(_ gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil &&
            indexPath!.section == 0 &&
            indexPath!.row == 0 {
            return
        }
        descriptionLabel.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.delegate = self
            controller.selectedCategoryName = categoryName
        }
    }
    
    
}

// MARK: - TableView Delegate

extension LocationDetailsViewController {
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1{
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionLabel.becomeFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 88.0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}

// MARK: - CategoryPicker Delegate

extension LocationDetailsViewController: CategoryPickerViewControllerDelegate {
    func CategoryPickerViewController(controller: CategoryPickerViewController, didPicked category: String) {
        categoryName = category
        categoryLabel.text = categoryName
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Private Methods

extension LocationDetailsViewController {
    
    private func displayLabels() {
        
        descriptionLabel.text = descriptionName
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude )
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        }
        dateLabel.text = dateFormatter.string(from: date)
    }
    
    private func string(from placemark: CLPlacemark) -> String {
        var text1 = " "
        if let s = placemark.subThoroughfare {
            text1 += s + " "
        }
        if let s = placemark.thoroughfare {
            text1 += s + ", "
        }
        var text2 = " "
        if let s = placemark.locality {
            text2 += s + ", "
        }
        if let s = placemark.administrativeArea {
            text2 += s + ", "
        }
        if let s = placemark.country {
            text2 += s + " ."
        }
        return text1 + "\n" + text2
    }
    
    private func saveIntoCoreData(for location: Location) {
        location.locationDescription = descriptionLabel.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
    }
}
