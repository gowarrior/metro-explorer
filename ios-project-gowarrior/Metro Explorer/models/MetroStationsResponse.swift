//
//  MetroStationsResponse.swift
//  Metro Explorer
//
//  Created by XYZ on 11/21/18.
//  Copyright © 2018 XYZ. All rights reserved.
//

import Foundation
//the capitalization matters

struct MetroStationsResponse: Codable {
    
    let Stations: [Station]
    
}

struct Station: Codable {
    
    let Code: String
    let Name: String
//    let stationTogether1: String
//    let stationTogether2: String
//    let lineCode1: String
//    let lineCode2: String?
//    let lineCode3: String?
//    let lineCode4: String?
    let Lat: Double
    let Lon: Double
//    let address: Address?
}

//struct Address: Codable {
//
//    let street: String
//    let city: String
//    let state: String
//    let zip: String
//
//}

