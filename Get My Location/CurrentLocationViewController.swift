//
//  ViewController.swift
//  Get My Location
//
//  Created by Amin  on 6/17/21.
//  Copyright © 2021 AhmedAmin. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController {
    
    // Instance Variables
    let locationManager = CLLocationManager()
    var location: CLLocation?
    
    // Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    
    // Actions
    @IBAction func getLocation(_ sender: UIButton) {
        
        // Ask Permission
        askLocationPermission()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    
    // MARK: - View controller lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the first start up
        updateLabels()
    }
    
    
}

// MARK: - CLLocationManager delegate

extension CurrentLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithErrors:- \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        location = newLocation
        updateLabels()
        print("didUpdateLocation:- \(newLocation)")
        
    }
    
    
}


// MARK: - Private Methods

extension CurrentLocationViewController {
    
    private func askLocationPermission() {
        
        // Get ask permission
        let authoSatus = CLLocationManager.authorizationStatus()
        if authoSatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        if authoSatus == .denied || authoSatus == .restricted {
            showLocationServicesDeniedAlert()
        }
        return
    }
    
    private func showLocationServicesDeniedAlert() {
        
        let alert = UIAlertController(title: "Location Service Disabled.", message: "Please enable location service for this app in settings", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            messageLabel.text = ""
            tagButton.isHidden = false
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            messageLabel.text = "Tap 'Get My Location' to start"
            tagButton.isHidden = true
        }
    }
}

