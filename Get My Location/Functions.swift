//
//  Functions.swift
//  Get My Location
//
//  Created by Amin  on 6/17/21.
//  Copyright © 2021 AhmedAmin. All rights reserved.
//

import Foundation



func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

// Get core data file directory
let applicationDocumentDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

// Core Data failed Save Notification
let coreDataSaveFailedNotification = Notification.Name(rawValue: "coreDataSaveFailedNotification")
func fatalCoreDataError(_ error: Error) {
    print("Fatal Error \(error)")
    NotificationCenter.default.post(name: coreDataSaveFailedNotification, object: nil)
}

