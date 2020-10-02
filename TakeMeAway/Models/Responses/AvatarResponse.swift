//
//  AvatarResponse.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal
import Moya_Marshal

final class AvatarResponse: NSObject, Unmarshaling {
    
    let status: Int
    let errorMessage: String?
    let data: String?
    
    init (status: Int, errorMessage: String?, data: String?) {
        self.status = status
        self.errorMessage = errorMessage
        self.data = data
    }
    
    init(object: MarshaledObject) throws {
        status = try object.value(for: "status")
        errorMessage = try object.value(for: "errorMessage")
        data = try object.value(for: "avatar")
    }
}
