//
//  UserResponse.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal
import Moya_Marshal

final class UserResponse: NSObject, Unmarshaling {
    
    let status: Int
    let data: User?
    let errorMessage: String?
    
    init (status: Int, data: User?, errorMessage: String?) {
        self.status = status
        self.data = data
        self.errorMessage = errorMessage
    }
    
    init(object: MarshaledObject) throws {
        status = try object.value(for: "status")
        data = try object.value(for: "userdata")
        errorMessage = try object.value(for: "errorMessage")
    }
}
