//
//  CurrentUserResponse.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 13/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal
import Moya_Marshal

final class CurrentUserResponse: NSObject, Unmarshaling {
    
    let status: Int
    let data: CurrentUser?
    let errorMessage: String?
    
    init (status: Int, data: CurrentUser?, errorMessage: String?) {
        self.status = status
        self.data = data
        self.errorMessage = errorMessage
    }
    
    init(object: MarshaledObject) throws {
        status = try Int(object.value(for: "status") as String)!
        data = try CurrentUser(user:object.value(for: "data"))
        errorMessage = try object.value(for: "errorMessage")
    }
}
