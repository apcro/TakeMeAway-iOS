//
//  HelpManager.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 13/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import UIKit

final class HelpManager {
    fileprivate var dataManager: DataManager
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    // data models
    let faqURL: String = "https://www.takemeaway.io/m.faq"
    let termsURL: String = "https://www.takemeaway.io/m.terms"
    let privacyURL: String = "https://www.takemeaway.io/m.privacy"
    
    let onboardingPages: [UIImage] = [
        UIImage(named: "newtutorial1")!,
        UIImage(named: "newtutorial1a")!,
        UIImage(named: "newtutorial3")!,
        UIImage(named: "newtutorial2")!,
        UIImage(named: "newtutorial4")!,
        UIImage(named: "newtutorial5")!,
        UIImage(named: "newtutorial6")!
    ]
    
}

extension HelpManager {
    //    MARK:- Public API
    //    These methods should be custom tailored to read specific data subsets,
    //    as required for specific views. These will be called by Coordinators,
    //    then routed into UIViewControllers
    
    
}


fileprivate extension HelpManager {
    //    MARK:- Private API
    //    These are thin wrappers around DataManager‘s similarly named methods.
    //    They are used to process received data and splice and dice them as needed,
    //    into business logic that only CatalogManager knows about
    
    
}
