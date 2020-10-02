//
//  AirportDetailsResponse.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 25/02/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//


import Marshal
import Moya_Marshal

final class AirportDetailsResponse: NSObject, Unmarshaling {
    
    let status: Int
    let data: Airport
    
    init (status: Int, data: Airport) {
        self.status = status
        self.data = data
    }
    
    init(object: MarshaledObject) throws {
        status = try object.value(for: "status")
        
        let iata: String = try object.value(for: "iata")
        let name: String = try object.value(for: "name")
        let city: String = try object.value(for: "city")
        let lat: Float = try Float(object.value(for: "lat") as String)!
        let lon: Float = try Float(object.value(for: "lon") as String)!
        
        data = Airport(iata: iata, name: name, city: city, lat: lat, lon: lon)
    }
}
