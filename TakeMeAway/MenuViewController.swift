//
//  MenuViewController.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 03/12/2017.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit
import Kingfisher

protocol SideMenuDelegate {
    func menuItemWasSelected()
}

class MenuViewController: UIViewController {
    
    var delegate: SideMenuDelegate?
    
    struct MenuItem {
        var title: String
        var icon: UIImage?
        var action: () -> Void
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var sections: [[MenuItem]] = []
    
    var currentUser: User? {
        didSet {
            // render labels and shit
            renderUserData()
            populateMenu()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure menu items
        populateMenu()

        // configure tableview
        tableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        tableView.register(UINib(nibName: "MenuSectionSeparator", bundle: nil), forHeaderFooterViewReuseIdentifier: "MenuSeparator")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        // configure views
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.borderWidth = 1.0
        avatarImageView.layer.borderColor = UIColor.TMAColors.LightTeal.cgColor
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.width / 2.0
        
        // set font family for all my view's subviews
        setFontFamilyForView("Muli-Regular", view: view, andSubviews: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateMenu() {
        if currentUser != nil {
            // logged in
            let section1 = [
                MenuItem(title: "Profile", icon: UIImage(named: "ic2_profile"), action: { self.accountShowPage(AccountPageBox(.profile), sender: self) }),
                MenuItem(title: "Filters", icon: UIImage(named: "ic2_filters"), action: { self.accountShowPage(AccountPageBox(.filters), sender: self) }),
                MenuItem(title: "My Saved Items", icon: UIImage(named: "ic2_save"), action: { self.destinationShowPage(DestinationPageBox(.savedItems), sender: self)})
            ]
            
            let section2 = [
                MenuItem(title: "Terms & Conditions", icon: UIImage(named: "ic2_about"), action: { self.helpShowPage(HelpPageBox(.termsAndConditions), sender: self) }),
                MenuItem(title: "Privacy Policy", icon: UIImage(named: "ic2_about"), action: { self.helpShowPage(HelpPageBox(.privacy), sender: self) }),
                MenuItem(title: "Frequently Asked Questions", icon: UIImage(named: "ic2_faq"), action: { self.helpShowPage(HelpPageBox(.faq), sender: self) }),
                MenuItem(title: "Send Feedback", icon: UIImage(named: "ic2_feedback"), action: { self.helpShowPage(HelpPageBox(.feedback), sender: self) })
            ]
            
            let section3 = [
                MenuItem(title: "Logout", icon: UIImage(named: "ic2_logout"), action: { self.logout(sender: self) })
            ]
            
            sections = [section1, section2, section3]
        } else {
            // logged out
            let section1 = [
                MenuItem(title: "Register", icon: UIImage(named: "ic2_register"), action: { self.accountShowPage(AccountPageBox(.register), sender: self) }),
                MenuItem(title: "Login", icon: UIImage(named: "ic2_login"), action: { self.accountShowPage(AccountPageBox(.login), sender: self) }),
            ]
            
            let section2 = [
                MenuItem(title: "Terms & Conditions", icon: UIImage(named: "ic2_about"), action: { self.helpShowPage(HelpPageBox(.termsAndConditions), sender: self) }),
                MenuItem(title: "Privacy Policy", icon: UIImage(named: "ic2_about"), action: { self.helpShowPage(HelpPageBox(.privacy), sender: self) }),
                MenuItem(title: "Frequently Asked Questions", icon: UIImage(named: "ic2_faq"), action: { self.helpShowPage(HelpPageBox(.faq), sender: self) })
            ]
            
            sections = [section1, section2]
        }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // subscribe to user account notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleLogIn(notification:)), name: NSNotification.Name("USER_LOGGED_IN"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleLogOut(notification:)), name: NSNotification.Name("USER_LOGGED_OUT"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // unsubscribe to user account notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: Tableview Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuTableViewCell
        let item = sections[indexPath.section][indexPath.row]
        cell.titleLabel.text = item.title
        cell.iconView.image = item.icon
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MenuSeparator")
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // don't show footer for last section
        return (section == self.sections.count - 1) ? 0.0 : 1.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    // MARK: Tableview Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get data model and execute action
        let item = sections[indexPath.section][indexPath.row]
        item.action()
        
        // reset selection
        tableView.deselectRow(at: indexPath, animated: true)
        
        // notify delegate so we can close the menu or something
        delegate?.menuItemWasSelected()
    }
}

fileprivate extension MenuViewController {
    func renderUserData() {
        self.nameLabel.text = "\(currentUser?.firstName ?? "") \(currentUser?.lastName ?? "")"
        self.emailLabel.text = "\(currentUser?.email ?? "")"
        if let avatar = currentUser?.avatar {
            let url = URL(string: avatar)
            self.avatarImageView.kf.setImage(with: url)
        } else {
            self.avatarImageView.image = UIImage(named: "ic2_profile")
        }
        
    }
    
    @objc func handleLogIn(notification: Notification) {
        if let user = notification.object as? User {
            currentUser = user
        }
    }
    
    @objc func handleLogOut(notification: Notification) {
        currentUser = nil
    }
}
