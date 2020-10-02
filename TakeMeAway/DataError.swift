//
//  DataError.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 05/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal

enum DataError: Error {
    case internalError
    case insufficientInput
    case missingData
    case noDestinations
    
    case takeMeAwayServiceError(TakeMeAwayServiceError)
    case marshalError(MarshalError)
}


extension DataError: CustomStringConvertible {
    var description: String {
        switch self {
        case .internalError:
            return "Internal Error"
        case .insufficientInput:
            return "Insufficient input parameters"
        case .missingData:
            return "No data available at the moment"
        case .noDestinations:
            return "No destinations available"
        case .takeMeAwayServiceError:    //TODO: improve this
            return "Internal error"
        case .marshalError:
            return "Data parsing error"
        }
    }
}
