//
//  SingleDestinationResponse.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 12/02/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal
import Moya_Marshal

final class SingleDestinationResponse: NSObject, Unmarshaling {
    
    let status: Int
    let data: Destination
    let errorMessage: String?
    
    init (status: Int, data: Destination, errorMessage: String?) {
        self.status = status
        self.data = data
        self.errorMessage = errorMessage
    }
    
    init(object: MarshaledObject) throws {
        status = try object.value(for: "status")
        data = try object.value(for: "data")
        errorMessage = try object.value(for: "errorMessage")
    }
}

