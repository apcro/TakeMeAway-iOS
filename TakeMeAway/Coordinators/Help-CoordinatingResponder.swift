//
//  Help-CoordinatingResponder.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit


final class HelpPageBox: NSObject {
    let unbox: HelpCoordinator.Page
    init(_ value: HelpCoordinator.Page) {
        self.unbox = value
    }
}
extension HelpCoordinator.Page {
    var boxed: HelpPageBox { return HelpPageBox(self) }
}


extension UIResponder {
    
    @objc dynamic func submitFeedback(sender: Any?, feedback: String, completion: @escaping (Error?) -> Void) {
        coordinatingResponder?.submitFeedback(sender: sender, feedback: feedback, completion: completion)
    }
    
    
}
