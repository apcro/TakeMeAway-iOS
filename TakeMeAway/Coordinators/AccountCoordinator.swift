//
//  AccountCoordinator.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Coordinator

final class AccountCoordinator: NavigationCoordinator, NeedsDependency {
    var dependencies: AppDependency? {
        didSet { updateChildCoordinatorDependencies() }
    }
    
    //    Declaration of all local pages (ViewControllers)
    enum Page {
        case login
        case register
        case profile
        case filters
    }
    var page: Page = .login
    
    func display(page: Page) {
        rootViewController.parentCoordinator = self
        rootViewController.delegate = self
        
        setupActivePage(page)
    }
    
    //    Coordinator lifecycle
    override func start(with completion: @escaping () -> Void = {}) {
        super.start(with: completion)
        
        setupActivePage()
    }
    
    //    MARK:- Coordinating Messages
    //    must be placed here, due to current Swift/ObjC limitations
    
    override func facebookCompletedLogin( userId: String, token: String, sender: Any?, completion: @escaping (Bool) -> Void) {
        guard let loginManager = dependencies?.loginManager else {
            completion(false)
            return
        }
        loginManager.loginWithProvider(provider: .facebook, username: userId, password: nil, token: token, callback: { (success, loginResponse, error) in
            completion(success)
        })
    }
    
    override func twitterCompletedLogin( userId: String, token: String, sender: Any?, completion: @escaping (Bool) -> Void) {
        guard let loginManager = dependencies?.loginManager else {
            completion(false)
            return
        }
        loginManager.loginWithProvider(provider: .twitter, username: userId, password: nil, token: token, callback: { (success, loginResponse, error) in
            completion(success)
        })
    }
    
    override func dismissLoginRegister(sender: Any?) {
        parent?.coordinatorDidFinish(self, completion: {})
    }
    
    override func getNearestAirport(lat: Float, lon: Float, completion: @escaping (Airport?, Error?) -> Void) {
        guard let manager = dependencies?.dataManager else {
            completion(nil, AccountError.custom("Could not get datamanager"))
            return
        }
        manager.getNearestAirport(lat: lat, lon: lon, callback: completion)
    }
    
    override func getAirportDetails(iata: String, completion: @escaping (Airport?, Error?) -> Void) {
        guard let manager = dependencies?.dataManager else {
            completion(nil, AccountError.custom("Could not get datamanager"))
            return
        }
        manager.getAirportDetails(iata: iata, callback: completion)
    }
    
    override func updateUserSettings(user: User, sender: Any?, completion: @escaping (Error?) -> Void) {
        guard let manager = dependencies?.accountManager else {
            completion(AccountError.notLoggedIn)
            return
        }
        manager.updateUserSettings(user: user, sender: self, completion: completion)
    }
    
    override func updateUserProfile(user: User, sender: Any?, completion: @escaping (Error?) -> Void) {
        guard let manager = dependencies?.accountManager else {
            completion(AccountError.notLoggedIn)
            return
        }
        manager.updateUserProfile(user: user, sender: self, completion: completion)
    }
    
    override func getAirports(lat: Float, lon: Float, sender: Any?, completion: @escaping ([Airport], Error?) -> Void) {
        print("get airports override func in account coordinator")
        
        guard let manager = dependencies?.accountManager else {
            completion([], AccountError.custom("Could not get datamanager"))
            return
        }
        print("calling get airports in datamanager")
        manager.getAirports(lat: lat, lon: lon, sender: self, completion: completion)
        
    }
    
    override func updateAvatar(avatar: UIImage, sender: Any?, completion: @escaping (Error?) -> Void) {
        guard let manager = dependencies?.accountManager else {
            completion(AccountError.notLoggedIn)
            return
        }
        manager.updateAvatar(avatar: avatar, sender: sender, completion: completion)
    }
    
    override func fetchCurrentUser(sender: Any?, completion: @escaping (User?, Error?) -> Void) {
        guard let manager = dependencies?.accountManager else {
            completion(nil, AccountError.notLoggedIn)
            return
        }
        manager.currentUser(callback: { (user, error) in
            guard let user = user else {
                completion(nil, error)
                return
            }
            completion(user, nil)
        })
        
    }
    
    override func loginWithCredentials(sender: Any?, username: String, password: String, completion: @escaping (Bool) -> Void) {
        if let loginManager = dependencies?.loginManager {
            loginManager.loginWithProvider(provider: .takeMeAway, username: username, password: password, token: nil) { (success, response, error) in
                completion(success)
            }
        }
    }
    
    override func registerWithCredentials(sender: Any?, name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        if let loginManager = dependencies?.loginManager {
            loginManager.registerAccount(name: name, email: email, password: password) { (success, response, error) in
                completion(success)
            }
        }
    }
    
}

fileprivate extension AccountCoordinator {
    func setupActivePage(_ enforcedPage: Page? = nil) {
        let p = enforcedPage ?? page
        page = p
        
        switch p {
        case .login:
            let vc = LoginRegisterViewController(formMode: .login, nibName: "LoginRegisterViewController", bundle: nil)
            show(vc)
        case .register:
            let vc = LoginRegisterViewController(formMode: .register, nibName: "LoginRegisterViewController", bundle: nil)
            show(vc)
            
        case .profile:
            let vc = ProfileFormViewController()
            if let accountManager = dependencies?.accountManager {
                vc.user = accountManager.currentUser
            }
            show(vc)
            
        case .filters:
            let vc = FiltersFormViewController.init()
            show(vc)
        }
    }
}
