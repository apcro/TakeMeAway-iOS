//
//  HotelAvailabilitiesResponse.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal
import Moya_Marshal

final class HotelAvailabilitiesResponse: NSObject, Unmarshaling {
    
    let status: Int
    let data: [HotelAvailability]?
    
    init (status: Int, data: [HotelAvailability]) {
        self.status = status
        self.data = data
    }
    
    init(object: MarshaledObject) throws {
        status = try Int(object.value(for: "status") as String)!
        data = try object.value(for: "data")
    }
}
