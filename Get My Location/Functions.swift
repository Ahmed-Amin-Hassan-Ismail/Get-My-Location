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
