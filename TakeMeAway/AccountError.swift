//
//  AccountError.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 21/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation

public enum AccountError: Error {
    //    case network(NetworkError?)
    case notLoggedIn
    case custom(String)
}

extension AccountError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notLoggedIn:
            return "No user is logged in."
        case .custom(let reason):
            return reason
        }
    }
}
