import Foundation
import Result
import Moya

// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim

// MARK: - TakeMeAwayTokenPlugin


/**
 A plugin for adding necessary Token header to TakeMeAway API requests
 ```
 
 */
public struct TakeMeAwayTokenPlugin: PluginType {
    
    /// A closure returning the access token to be applied in the header.
    public let tokenClosure: () -> String
    
    /**
     Initialize a new `TakeMeAwayTokenPlugin`.
     
     - parameters:
     - tokenClosure: A closure returning the token to be applied in the pattern `Token: <token>`
     */
    public init(tokenClosure: @escaping @autoclosure () -> String) {
        self.tokenClosure = tokenClosure
    }
    
    /**
     Prepare a request by adding an authorization header if necessary.
     
     - parameters:
     - request: The request to modify.
     - target: The target of the request.
     - returns: The modified `URLRequest`.
     */
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let authorizable = target as? AccessTokenAuthorizable else { return request }
        
        let authorizationType = authorizable.authorizationType
        
        var request = request
        
        switch authorizationType {
        case .basic, .bearer:
            request.addValue(tokenClosure(), forHTTPHeaderField: "Token")
        case .none:
            break
        }
        
        return request
    }
}

