//
//  AppDependency.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Coordinator
import CoreData


//    Dummy objects, placeholders for real ones
final class Keychain {}

//    Dependency carrier through the app,
//    injected into every Coordinator
struct AppDependency {
    var apiManager: TakeMeAwayService?
    var dataManager: DataManager?
    var loginManager: LoginManager?
    var keychainProvider: Keychain?
    var destinationManager: DestinationManager?
    var helpManager: HelpManager?
    var accountManager: AccountManager?
    
    init(apiManager: TakeMeAwayService? = nil,
         dataManager: DataManager? = nil,
         loginManager: LoginManager? = nil,
         keychainProvider: Keychain? = nil,
         destinationManager: DestinationManager? = nil,
         helpManager: HelpManager? = nil,
         accountManager: AccountManager? = nil)
    {

        self.apiManager = apiManager
        self.loginManager = loginManager
        self.keychainProvider = keychainProvider
        self.dataManager = dataManager
        self.destinationManager = destinationManager
        self.helpManager = helpManager
        self.accountManager = accountManager
    }
}

final class AppDependencyBox: NSObject {
    let unbox: AppDependency
    init(_ value: AppDependency) {
        self.unbox = value
    }
}

extension AppDependency {
    var boxed: AppDependencyBox { return AppDependencyBox(self) }
}
