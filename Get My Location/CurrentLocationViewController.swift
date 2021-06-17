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
    
    // Location Manager Instance
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var timer: Timer?
    
    // Handle GPS Errors
    var updatingLocations = false
    var lastLocationError: Error?
    
    // Reverse Geocoding Instance
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    
    // Handle Geocoding Errors
    var performingReverseGeocoding = false
    var lastGeocodingErrors: Error?
    
    
    // Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel! {
        didSet {
            addressLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    
    // Actions
    @IBAction func getLocation(_ sender: UIButton) {
        
        // Ask Permission
        askLocationPermission()
        
        // Start Get the location
        if updatingLocations {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            startLocationManager()
        }
        updateLabels()
    }
    
    
    // MARK: - View controller lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the first start up
        updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.isNavigationBarHidden = false 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tagLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
        }
    }
}

// MARK: - CLLocationManager delegate

extension CurrentLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        
        // Get accuracy reult
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        if location == nil || (location!.horizontalAccuracy > newLocation.horizontalAccuracy) {
            // Clear old result and update
            lastLocationError = nil
            location = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                stopLocationManager()
                if distance >= 0 {
                    performingReverseGeocoding = false
                }
            }
            updateLabels()
            
            // Reverse Geocoding
            if !performingReverseGeocoding {
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation) {
                    (placemarks, errors) in
                    if let error = errors {
                        self.lastGeocodingErrors = error
                        self.placemark = nil
                    }
                    if errors == nil,
                        let placemarks = placemarks,
                        !placemarks.isEmpty {
                        self.placemark = placemarks.last
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                }
            } else if distance < 1 {
                let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
                if timeInterval > 10 {
                    stopLocationManager()
                    updateLabels()
                }
            }
        }
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
    
    private func updateLabels() {
        
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            messageLabel.text = ""
            tagButton.isHidden = false
            
            // Get the Address
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for address..."
            } else if lastGeocodingErrors != nil {
                addressLabel.text = "Error Finding Address!"
            } else {
                addressLabel.text = "No Address Found"
            }
            
        } else {
            let statusMessage: String
            
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocations {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to start"
            }
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            messageLabel.text = statusMessage
            tagButton.isHidden = true
        }
        configureGetButton()
    }
    
    private func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
            updatingLocations = true
        }
    }
    
    @objc func didTimeOut() {
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationErrorDomain", code: 0, userInfo: nil)
            updateLabels()
        }
    }
    
    private func stopLocationManager() {
        if updatingLocations {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            if let timer = timer {
                timer.invalidate()
            }
            updatingLocations = false
        }
    }
    
    private func showLocationServicesDeniedAlert() {
        
        let alert = UIAlertController(title: "Location Service Disabled.", message: "Please enable location service for this app in settings", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func configureGetButton() {
        if updatingLocations {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    private func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        if let s = placemark.thoroughfare {
            line1 += s
        }
        
        var line2 = ""
        if let s = placemark.locality {
            line2 += s + ", "
        }
        if let s = placemark.administrativeArea {
            line2 += s + ", "
        }
        if let s = placemark.country {
            line2 += s + " ."
        }
        return line1 + "\n" + line2
    }
    
}

