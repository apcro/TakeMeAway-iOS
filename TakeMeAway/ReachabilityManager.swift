//
//  ReachabilityManager.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 14/02/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Alamofire

final class ReachabilityManager {
    
    private var reachable = true
    private var connectionType: NetworkReachabilityManager.NetworkReachabilityStatus?
    private let manager: NetworkReachabilityManager! = NetworkReachabilityManager(host: "api.takemeaway.io")
    
    required init() {
        
        manager.listener = { status in
            
            print("Network Status Changed: \(status)")
            print("network reachable \(self.manager!.isReachable)")
            
            self.reachable = self.manager.isReachable
            self.connectionType = status
            
            
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: .reachabilityChanged, object: status)
        }
        
        manager.startListening()
    }
    
    deinit {
        manager.stopListening()
    }
    
    public func isOnline() -> Bool {
        let online = reachable
        
        return online
    }
}
