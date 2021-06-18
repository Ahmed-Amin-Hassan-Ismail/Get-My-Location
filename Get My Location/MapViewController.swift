//
//  MapViewController.swift
//  Get My Location
//
//  Created by Amin  on 6/18/21.
//  Copyright © 2021 AhmedAmin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController {
    
    // Core Data variable
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: self.managedObjectContext, queue: .main) { (_) in
                if self.isViewLoaded {
                    self.updateLocation()
                }
            }
        }
    }
    
    // instance variables
    var locations = [Location]()
    
    // Outlet
    @IBOutlet weak var mapView: MKMapView!
    
    // Actions
    @IBAction func showUser(_ sender: Any) {
        
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
    }
    
    
    @IBAction func showLocation(_ sender: Any) {
        
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
        
    }
    
    
    // MARK:- VC LifeCycke
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // confirm to delegete
        mapView.delegate = self
        
        // Fetch from database
        updateLocation()
        
        // showing location on map
        if !locations.isEmpty {
            showLocation(self)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            let button = sender as! UIButton
            let location = locations[button.tag]
            controller.locationToEdit = location
        }
    }
}

// MARK: - MapView Delegate

extension MapViewController: MKMapViewDelegate {
    
    // Create a custom annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Location else { return nil}
        
        let identifier = "location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showLocationDetail(_:)), for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            annotationView = pinView
        }
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.firstIndex(of: annotation as! Location) {
                button.tag = index
            }
        }
        
        return annotationView
        
    }
    
    @objc func showLocationDetail(_ sender: UIButton) {
        
        performSegue(withIdentifier: "mapLocation", sender: sender)
    }
    
}

// MARK: - Helper methods

extension MapViewController {
    
    private func updateLocation() {
        mapView.removeAnnotations(locations)
        
        let fetchRequest = NSFetchRequest<Location>()
        let entity = Location.entity()
        fetchRequest.entity = entity
        
        do {
            locations = try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalCoreDataError(error)
        }
        
        mapView.addAnnotations(locations)
    }
    
    private func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        
        let region: MKCoordinateRegion
        switch annotations.count {
        case 0:
            region = MKCoordinateRegion(center: mapView.userLocation.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        case 1:
            let annotaion = annotations[annotations.count - 1]
            region = MKCoordinateRegion(center: annotaion.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        default:
            var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotaion in annotations {
                topLeftCoordinate.latitude = max(topLeftCoordinate.latitude, annotaion.coordinate.latitude)
                topLeftCoordinate.longitude = min(topLeftCoordinate.longitude, annotaion.coordinate.longitude)
                bottomRightCoordinate.latitude = min(bottomRightCoordinate.latitude, annotaion.coordinate.latitude)
                bottomRightCoordinate.longitude = max(bottomRightCoordinate.longitude, annotaion.coordinate.longitude)
            }
            let center = CLLocationCoordinate2D(
                latitude: topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) / 2,
                longitude: topLeftCoordinate.longitude - (topLeftCoordinate.longitude - bottomRightCoordinate.longitude) / 2)
            
            let extraSpace = 1.1
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoordinate.longitude - bottomRightCoordinate.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
        return mapView.regionThatFits(region)
    }
}
