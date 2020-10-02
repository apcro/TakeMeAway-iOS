//
//  NotificationNames.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 15/02/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation

extension Notification.Name {
    static let userLoggedOut = Notification.Name("USER_LOGGED_OUT")
    static let userLoggedIn = Notification.Name("USER_LOGGED_IN")
    static let avatarChanged = Notification.Name("AVATAR_CHANGED")
    static let reachabilityChanged = Notification.Name("REACHABILITY_CHANGED")
}
