//
//  MLandmark.swift
//  Metro Explorer
//
//  Created by XYZ on 11/24/18.
//  Copyright © 2018 XYZ. All rights reserved.
//

import Foundation

struct MLandmark : Codable {
    let id : String
    let name : String
    let lat: Double
    let lon: Double
    let address : String
    let imageUrl : String?
    let rating : Double
}
