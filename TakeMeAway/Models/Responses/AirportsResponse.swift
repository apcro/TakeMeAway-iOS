//
//  AirportsResponse.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal
import Moya_Marshal

final class AirportsResponse: NSObject, Unmarshaling {
    
    let status: Int
    let data: [Airport]
    
    init (status: Int, data: [Airport]) {
        self.status = status
        self.data = data
    }
    
    init(object: MarshaledObject) throws {
//        status = try Int(object.value(for: "status") as String)!
        status = try object.value(for: "status")
        data = try object.value(for: "data")
    }
}
