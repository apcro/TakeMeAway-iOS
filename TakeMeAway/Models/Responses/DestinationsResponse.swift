//
//  LoginResponse.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 06/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal
import Moya_Marshal

final class DestinationsResponse: NSObject, Unmarshaling {
    
    let status: Int
    let data: [Destination]
    let errorMessage: String?
    let error: String?
    
    init (status: Int, data: [Destination], errorMessage: String?, error: String?) {
        self.status = status
        self.data = data
        self.errorMessage = errorMessage
        self.error = error
    }
    
    init(object: MarshaledObject) throws {
        status = try object.value(for: "status")
        data = try object.value(for: "data")
        error = try object.value(for: "error")
        errorMessage = try object.value(for: "errorMessage")
    }
}
