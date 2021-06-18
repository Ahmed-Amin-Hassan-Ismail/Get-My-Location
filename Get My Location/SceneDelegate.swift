//
//  SceneDelegate.swift
//  Get My Location
//
//  Created by Amin  on 6/17/21.
//  Copyright © 2021 AhmedAmin. All rights reserved.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // CoreDate object to call the object for one time
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { (storeDiscription, errors) in
            if let error = errors {
                fatalError("Could not load data store \(error)")
            }
        }
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext
    
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // Pass Managed Object Context
        let tabBar = window?.rootViewController as! UITabBarController
        if let tabBarViewController = tabBar.viewControllers {
            
            // For the First Tab
            var navigationController = tabBarViewController[0] as! UINavigationController
            let currentViewController = navigationController.viewControllers.first  as! CurrentLocationViewController
            currentViewController.managedObjectContext = managedObjectContext
            
            // For the Second Tab
            navigationController = tabBarViewController[1] as! UINavigationController
            let locationViewController = navigationController.viewControllers.first as! LocationsViewController
            locationViewController.managedObjectContext = managedObjectContext
            let _ = locationViewController.view
            
            // For the Third Tab
            navigationController = tabBarViewController[2] as! UINavigationController
            let mapViewController = navigationController.viewControllers.first as! MapViewController
            mapViewController.managedObjectContext = managedObjectContext
            let _ = mapViewController.view
        }
        print("Application Document Directory \(applicationDocumentDirectory)")
        listenFatalCoreDataNotification()
    }
    
    
    private func listenFatalCoreDataNotification() {
        NotificationCenter.default.addObserver(forName: coreDataSaveFailedNotification, object: nil, queue: .main) { (notification) in
            let message = """
               there was a fata error in the app and cannot continue.
               press 'Ok' to terminate the app. sorry for inconvenience.
               """
            let alert = UIAlertController(title: "Internal Error", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "ok", style: .default) { (_) in
                let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "fatal Core Data Error", userInfo: nil)
                exception.raise()
            }
            alert.addAction(action)
            let tabController = self.window!.rootViewController!
            tabController.present(alert, animated: true, completion: nil)
            
        }
    }
    
}

