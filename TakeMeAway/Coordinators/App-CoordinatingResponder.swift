//
//  App-CoordinatingResponder.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 27/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit

extension UIResponder {
    @objc dynamic func currentUser(sender: Any?) -> User? {
        return coordinatingResponder?.currentUser(sender: sender)
    }
    
    @objc dynamic func isLoggedIn(sender: Any?) -> Bool {
        return coordinatingResponder?.isLoggedIn(sender:sender) ?? false
    }
    
    @objc dynamic func wrapPrice(_ price: Any, sender: Any? = nil) -> String {
        if let responder = coordinatingResponder {
            return responder.wrapPrice(price)
        } else {
            return "£\(price)"
        }
    }
    
    @objc dynamic func tripNights(_ leaveDay: String, _ returnDay: String, sender: Any? = nil) -> String {
        if let responder = coordinatingResponder {
            return responder.tripNights(leaveDay, returnDay)
        } else {
            return "2"
        }
    }
    
    @objc dynamic func didChangeFilters(sender: Any?) {
        coordinatingResponder?.didChangeFilters(sender: sender)
    }
    
    @objc dynamic func didLogin(sender: Any?) {
        coordinatingResponder?.didLogin(sender: sender)
    }
    
    @objc dynamic func didLogout(sender: Any?) {
        coordinatingResponder?.didLogout(sender: sender)
    }
    
    @objc dynamic func dismissHelp(sender: Any?) {
        coordinatingResponder?.dismissHelp(sender: sender)
    }
    
    
    //    ** Switching to different VCs
    @objc dynamic func helpShowPage(_ page: HelpPageBox, sender: Any?) {
        coordinatingResponder?.helpShowPage(page, sender: sender)
    }
    
    @objc dynamic func destinationShowPage(_ page: DestinationPageBox, sender: Any?) {
        coordinatingResponder?.destinationShowPage(page, sender: sender)
    }
    
    @objc dynamic func accountShowPage(_ page: AccountPageBox, sender: Any?) {
        coordinatingResponder?.accountShowPage(page, sender: sender)
    }

}
