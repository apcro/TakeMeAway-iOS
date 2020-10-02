//
//  Account-CoordinatingResponder.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import UIKit

final class AccountPageBox: NSObject {
    let unbox: AccountCoordinator.Page
    init(_ value: AccountCoordinator.Page) {
        self.unbox = value
    }
}
extension AccountCoordinator.Page {
    var boxed: AccountPageBox { return AccountPageBox(self) }
}


extension UIResponder {
    
    @objc dynamic func facebookCompletedLogin( userId: String, token: String, sender: Any?, completion: @escaping (Bool) -> Void) {
        coordinatingResponder?.facebookCompletedLogin(userId: userId, token: token, sender: sender, completion: completion)
    }
    
    @objc dynamic func twitterCompletedLogin( userId: String, token: String, sender: Any?, completion: @escaping (Bool) -> Void) {
        coordinatingResponder?.twitterCompletedLogin(userId: userId, token: token, sender: sender, completion: completion)
    }
    
    @objc dynamic func dismissLoginRegister(sender: Any?) {
        coordinatingResponder?.dismissLoginRegister(sender: sender)
    }
    
    @objc dynamic func getNearestAirport(lat: Float, lon: Float, completion: @escaping (Airport?, Error?) -> Void) {
        coordinatingResponder?.getNearestAirport(lat: lat, lon: lon, completion: completion)
    }
    
    @objc dynamic func getAirportDetails(iata: String, completion: @escaping (Airport?, Error?) -> Void) {
        coordinatingResponder?.getAirportDetails(iata: iata, completion: completion)
    }

    @objc dynamic func getAirports(lat: Float, lon: Float, sender: Any?, completion: @escaping ([Airport], Error?) -> Void) {
        coordinatingResponder?.getAirports(lat: lat, lon: lon, sender: sender, completion: completion)
    }
    
    @objc dynamic func updateUserProfile(user: User, sender: Any?, completion: @escaping (Error?) -> Void) {
        coordinatingResponder?.updateUserProfile(user: user, sender: sender, completion: completion)
    }
    
    @objc dynamic func updateUserSettings(user: User, sender: Any?, completion: @escaping (Error?) -> Void) {
        coordinatingResponder?.updateUserSettings(user: user, sender: sender, completion: completion)
    }
    
    @objc dynamic func updateAvatar(avatar: UIImage, sender: Any?, completion: @escaping (Error?) -> Void) {
        coordinatingResponder?.updateAvatar(avatar: avatar, sender: sender, completion: completion)
    }

    @objc dynamic func loginWithCredentials(sender: Any?, username: String, password: String, completion: @escaping (Bool) -> Void) {
        coordinatingResponder?.loginWithCredentials(sender: sender, username: username, password: password, completion: completion)
    }
    
    @objc dynamic func loginWithCredentialsAndProvider(sender: Any?, username: String, password: String, provider: String, completion: @escaping (Bool) -> Void) {
        coordinatingResponder?.loginWithCredentials(sender: sender, username: username, password: password, completion: completion)
    }
    
    @objc dynamic func logout(sender: Any?) {
        coordinatingResponder?.logout(sender: sender)
    }
    
    @objc dynamic func registerWithCredentials(sender: Any?, name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        coordinatingResponder?.registerWithCredentials(sender: sender, name: name, email: email, password: password, completion: completion)
    }
    
    @objc dynamic func fetchCurrentUser(sender: Any?, completion: @escaping (User?, Error?) -> Void) {
        coordinatingResponder?.fetchCurrentUser(sender: sender, completion: completion)
    }
    
    
}
