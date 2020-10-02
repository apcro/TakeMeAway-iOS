import Foundation
import Result
import Moya
import CryptoSwift

// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim

// MARK: - TakeMeAwayHMACPlugin


/**
 A plugin for adding necessary HMAC Authorisation header
 ```
 
 */
public struct TakeMeAwayHMACPlugin: PluginType {
    
    fileprivate let publicKey = "gl4n51shq45n-yghq234-89asit43"
    fileprivate let privateKey = "ven44p9wt8q3-lj4gb3q-2gbhw24p"
    fileprivate let salt = "gbrbalagagrvbl"
    
    
    /**
     Prepare a request by adding an authorization header if necessary.
     
     - parameters:
     - request: The request to modify.
     - target: The target of the request.
     - returns: The modified `URLRequest`.
     */
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        
        var request = request
        
        request.addValue(getAuthorisationHeaderValue(), forHTTPHeaderField: "Authorisation")
        
        return request
    }
    
    private func getAuthorisationHeaderValue() -> String {
        let timestamp = UInt64(Date().timeIntervalSince1970 * 1000)
        let hashSource = "\(timestamp)\(publicKey)\(salt)"
        let hash = getHash(source: hashSource, privateKey: privateKey)
        
        return "KeyAuth publicKey=\(publicKey) hash=\(hash) ts=\(timestamp)"
    }
    
    private func getHash(source: String, privateKey: String) -> String {
        // use cryptoswift to generate hash
        let key:Array<UInt8> = privateKey.bytes
        let bytes:Array<UInt8> = source.bytes
        do {
            let mac = try HMAC(key: key, variant: .sha256).authenticate(bytes).toHexString()
            return mac
        } catch {
            print(error)
            return ""
        }
        
    }
}


