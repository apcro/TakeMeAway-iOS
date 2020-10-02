//
//  Airport.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 05/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal

final class Airport: NSObject, Unmarshaling {
    let iata: String
    let name: String
    let city: String
    let lat: Float
    let lon: Float

    
    init(iata: String, name: String, city: String, lat: Float, lon: Float) {
        self.iata = iata
        self.name = name
        self.city = city
        self.lat = lat
        self.lon = lon
    }
    
    init(object: MarshaledObject) throws {
        iata = try object.value(for: "iata")
        name = try object.value(for: "name")
        city = try object.value(for: "city")
        lat = try Float(object.value(for: "lat") as String)!
        lon = try Float(object.value(for: "lon") as String)!
    }
    
}

