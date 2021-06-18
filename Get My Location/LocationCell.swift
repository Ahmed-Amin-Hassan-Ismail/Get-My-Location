//
//  LocationCell.swift
//  Get My Location
//
//  Created by Amin  on 6/18/21.
//  Copyright © 2021 AhmedAmin. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class LocationCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var addressLabel: UILabel! {
        didSet {
            addressLabel.numberOfLines = 0
        }
    }
    
    
    func configureCell(for location: Location) {
        
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "No Description"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        
        if let placemark = location.placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = String(format: "%.8f", "%.8f", location.latitude, location.longitude)
        }
        
        
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

}
