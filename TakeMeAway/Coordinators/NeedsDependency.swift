//
//  NeedsDependency.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Coordinator

//    Protocol you need to apply to all the Coordinators,
//    so the new `dependencies` value is propagated down
protocol NeedsDependency: class {
    var dependencies: AppDependency? { get set }
}

extension NeedsDependency where Self: Coordinating {
    func updateChildCoordinatorDependencies() {
        self.childCoordinators.forEach { (_, coordinator) in
            if let c = coordinator as? NeedsDependency {
                c.dependencies = dependencies
            }
        }
    }
}
