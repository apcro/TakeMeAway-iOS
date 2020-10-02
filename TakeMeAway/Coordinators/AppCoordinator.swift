//
//  AppCoordinator.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit
import Coordinator
import SVProgressHUD
import TwitterKit
import Eureka

final class AppCoordinator: NavigationCoordinator, NeedsDependency {
    var dependencies: AppDependency? {
        didSet {
            updateChildCoordinatorDependencies()
            processQueuedMessages()
        }
    }
    
    // user model
    var currentUser: User?
    
    // modals
    lazy var noInternetModal = NoInternetViewController.init(nibName: "NoInternetViewController", bundle: nil)
    
    //    AppCoordinator is root coordinator, top-level object in the UI hierarchy
    //    It keeps references to all the data source objects
    var reachabilityManager: ReachabilityManager!
    var loginManager: LoginManager!
    var dataManager: DataManager!
    var destinationManager: DestinationManager!
    var helpManager: HelpManager!
    var accountManager: AccountManager!
    
    // all app sections
    enum Section {
        case destination(DestinationCoordinator.Page?)
        case account(AccountCoordinator.Page?)
        case help(HelpCoordinator.Page?)
    }
    
    var section: Section = .destination(.chooseDestination)
    
    @objc func loginHandler(notification: Notification) {
        if notification.name == NSNotification.Name.userLoggedIn {
            self.currentUser = notification.object as? User
            self.dependencies?.accountManager?.userLoggedIn()
        } else if notification.name == NSNotification.Name.userLoggedOut {
            self.currentUser = nil
            self.dependencies?.accountManager?.userLoggedOut()
        }
    }
    
    @objc func reachabilityChanged(notification: Notification) {
        if reachabilityManager.isOnline() {
            // hide modal
            if rootViewController.presentedViewController == noInternetModal {
                rootViewController.dismiss(animated: true, completion: nil)
            }
        } else {
            // display modal
            rootViewController.present(noInternetModal, animated: true, completion: nil)
        }
    }
    
    func setEureka() {
        // set font for all row types
        ButtonRow.defaultCellSetup = { cell, row in
            if let label = cell.textLabel {
                label.font = UIFont(name: "Muli-Regular", size: label.font.pointSize)
                label.textColor = .red // ?
            }
        }
        NameRow.defaultCellSetup = { cell, row in
            if let label = cell.textLabel {
                label.font = UIFont(name: "Muli-Regular", size: label.font.pointSize)
            }
            cell.textField.font = UIFont(name: "Muli-Regular", size: cell.textField.font!.pointSize)
        }
        EmailRow.defaultCellSetup = { cell, row in
            if let label = cell.textLabel {
                label.font = UIFont(name: "Muli-Regular", size: label.font.pointSize)
            }
            cell.textField.font = UIFont(name: "Muli-Regular", size: cell.textField.font!.pointSize)
        }
        PasswordRow.defaultCellSetup = { cell, row in
            if let label = cell.textLabel {
                label.font = UIFont(name: "Muli-Regular", size: label.font.pointSize)
            }
            cell.textField.font = UIFont(name: "Muli-Regular", size: cell.textField.font!.pointSize)
        }
        
        SliderRow.defaultCellSetup = { cell, row in
            if let label = cell.textLabel {
                label.font = UIFont(name: "Muli-Regular", size: label.font.pointSize)
            }
        }
        SegmentedRow<String>.defaultCellSetup = { cell, row in
            // set font family and set back
            if let label = cell.textLabel {
                label.font = UIFont(name: "Muli-Regular", size: label.font.pointSize)
            }
        }
        SwitchRow.defaultCellSetup = { cell, row in
            if let label = cell.textLabel {
                label.font = UIFont(name: "Muli-Regular", size: label.font.pointSize)
            }
        }
        
        // set font for all row types
        ListCheckRow<String>.defaultCellSetup = { cell, row in
            if let label = cell.textLabel {
                label.font = UIFont(name: "Muli-Regular", size: label.font.pointSize)
            }
        }
    }

    
    override func start(with completion: @escaping () -> Void = {}) {
        
        // get/set hasRunBefore flag
        let userDefaults = UserDefaults.standard
        let hasRunBefore = userDefaults.bool(forKey: "hasRunBefore")

        if (!hasRunBefore) {
            section = .help(.onboarding)
        }
        
        // update the flag
        userDefaults.set(true, forKey: "hasRunBefore")
        userDefaults.synchronize() // forces the app to update the UserDefaults
        
        // set appearance proxies
        UINavigationBar.appearance().backgroundColor = UIColor.TMAColors.DarkTeal
        UINavigationBar.appearance().tintColor = UIColor.TMAColors.LightTeal
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.TMAColors.LightTeal]
        UINavigationBar.appearance().isTranslucent = false        
        
        // set default setup for Eureka form cells
        setEureka()
        
        // customise progress hud
        SVProgressHUD.setBackgroundColor(UIColor.TMAColors.DarkTeal)
        SVProgressHUD.setForegroundColor(UIColor.TMAColors.LightTeal)
        SVProgressHUD.setMinimumDismissTimeInterval(2.0)
        
        // listen for login/logout
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(loginHandler(notification:)), name: NSNotification.Name.userLoggedIn, object: nil)
        notificationCenter.addObserver(self, selector: #selector(loginHandler(notification:)), name: NSNotification.Name.userLoggedOut, object: nil)
        
        // listen for reachability changes
        notificationCenter.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityChanged, object: nil)
        
        // init TwitterKit
        TWTRTwitter.sharedInstance().start(withConsumerKey: "{key}", consumerSecret: "{secret}")  // TODO: move to plist

        // prepare managers
        self.reachabilityManager = ReachabilityManager()
        let api = TakeMeAwayService(reachabilityManager: reachabilityManager)
        self.dataManager = DataManager(api: api)
        self.loginManager = LoginManager(api: api, dataManager: dataManager, shouldClearKeychain: !hasRunBefore)
        
        if loginManager.status == .loggedOutSavedCredentials {
            // authenticate before loading other managers
            self.loginManager.loginWithSavedCreds() {(success, response, error) in
                if success {
                    self.currentUser = response?.userData
                } else {
                    // TODO: handle failed login - saved credentials invalid?
                }
                
            }
        } else if loginManager.status == .loggedIn {
            api.authToken = self.loginManager.authToken
            dataManager.fetchCurrentUser(callback: {(user, error) in
                if let user = user {
                    self.currentUser = user
                }
            })
        }

        accountManager = AccountManager(dataManager: dataManager)
        destinationManager = DestinationManager(dataManager: dataManager)
        helpManager = HelpManager(dataManager: dataManager)

        // load managers into dependencies object
        dependencies = AppDependency(apiManager: api, dataManager: dataManager, loginManager: loginManager, keychainProvider: nil, destinationManager: destinationManager, helpManager: helpManager, accountManager: accountManager)
        
        // finally ready
        super.start(with: completion)
        
        setupActiveSection()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //    MARK:- CoordinatingResponder
    override func didChangeFilters(sender: Any?) {
        // force reload of all cards in choose destination vc
        let identifier = String(describing: DestinationCoordinator.self)
        if let destCo = childCoordinators[identifier] as? DestinationCoordinator {
            destCo.reloadDestinationCards()
        }
    }
   
    override func didLogin(sender: Any?) {
        // force reload of all cards in choose destination vc
        let identifier = String(describing: DestinationCoordinator.self)
        if let destCo = childCoordinators[identifier] as? DestinationCoordinator {
            destCo.reloadDestinationCards()
        }
    }
    
    override func didLogout(sender: Any?) {
        // force reload of all cards in choose destination vc
        let identifier = String(describing: DestinationCoordinator.self)
        if let destCo = childCoordinators[identifier] as? DestinationCoordinator {
            destCo.reloadDestinationCards()
        }
    }
    
    override func isLoggedIn(sender: Any?) -> Bool {
        guard let loginManager = dependencies?.loginManager else {
            return false
        }
        if loginManager.status == .loggedIn || loginManager.status == .loggedOutSavedCredentials {
            return true
        }
        return false
    }
    
    override func currentUser(sender: Any?) -> User? {
        if let accountManager = dependencies?.accountManager {
            if let user = accountManager.currentUser {
                self.currentUser = user
            }
        }
        return currentUser
    }
    
    override func wrapPrice(_ price: Any, sender: Any? = nil) -> String {
        var symbol = "£"
        if let currency = currentUser?.currencyCode {
            switch currency {
                case "EUR":
                    symbol = "€"
                case "USD":
                    symbol = "$"
                default:
                    break
            }
        }
        return "\(symbol)\(price)"
    }
    
    override func tripNights(_ leaveDay: String, _ returnDay: String, sender: Any? = nil) -> String {
        var ld = 0;
        var rd = 0;
        if (leaveDay == "thursday") {
            ld = 0;
        }
        if (leaveDay == "friday") {
            ld = 1;
        }
        if (leaveDay == "saturday") {
            ld = 2;
        }
        if (returnDay == "sunday") {
            rd = 3;
        }
        if (returnDay == "monday") {
            rd = 4;
        }
        if (returnDay == "tuesday") {
            rd = 5;
        }
        
        return String.Value(rd - ld);
    }
    
    override func destinationShowPage(_ page: DestinationPageBox, sender: Any?) {
        setupActiveSection(.destination(page.unbox))
    }
    override func accountShowPage(_ page: AccountPageBox, sender: Any?) {
        // switch to account section and show requested page
        
        setupActiveSection(.account(page.unbox))
    }
    
    override func helpShowPage(_ page: HelpPageBox, sender: Any?) {
        
        setupActiveSection(.help(page.unbox))
    }
    
}


fileprivate extension AppCoordinator {
    
    //    MARK:- Internal API
    func setupActiveSection(_ enforcedSection: Section? = nil) {
        if let enforcedSection = enforcedSection {
            section = enforcedSection
        }
        switch section {
            case .destination(let page):
                showDestinations(page)
            case .help(let page):
                showHelp(page)
            case .account(let page):
                showAccount(page)
        }
    }
    
    func showDestinations(_ page: DestinationCoordinator.Page?) {
        let identifier = String(describing: DestinationCoordinator.self)
        //    if Coordinator is already created...
        if let c = childCoordinators[identifier] as? DestinationCoordinator {
            c.dependencies = dependencies
            //    just display this page
            if let page = page {
                c.display(page: page)
            }
            return
        }
        
        //    otherwise, create the coordinator and start it
        let c = DestinationCoordinator(rootViewController: rootViewController)
        c.dependencies = dependencies
        if let page = page {
            c.page = page
        }
        startChild(coordinator: c)
    }
    
    func showHelp(_ page: HelpCoordinator.Page?) {
        let identifier = String(describing: HelpCoordinator.self)
        //    if Coordinator is already created...
        if let c = childCoordinators[identifier] as? HelpCoordinator {
            c.dependencies = dependencies
            //    just display this page
            if let page = page {
                c.display(page: page)
            }
            return
        }
        
        //    otherwise, create the coordinator and start it
        let c = HelpCoordinator(rootViewController: rootViewController)
        c.dependencies = dependencies
        if let page = page {
            c.page = page
        }
        startChild(coordinator: c)
    }
    
    func showAccount(_ page: AccountCoordinator.Page?) {
        let identifier = String(describing: AccountCoordinator.self)
        //    if Coordinator is already created...
        if let c = childCoordinators[identifier] as? AccountCoordinator {
            c.dependencies = dependencies
            //    just display this page
            if let page = page {
                c.display(page: page)
            }
            return
        }
        
        //    otherwise, create the coordinator and start it
        let c = AccountCoordinator(rootViewController: rootViewController)
        c.dependencies = dependencies
        if let page = page {
            c.page = page
        }
        startChild(coordinator: c)
    }
}
