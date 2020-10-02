//
//  SidebarMenuViewController.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 05/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit

class SidebarMenuViewController: UIViewController {
    
    fileprivate let MENU_ANIM_DUR = 0.4

    @IBOutlet weak var shadeView: UIView!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var menuContainerTrailingEdge: NSLayoutConstraint!
    @IBAction func userDidPressMenuButton(_ sender: Any) {
        if !menuOpen {
            // open menu
            openMenu()
        } else { closeMenu() }
    }
    
    private var menuVC: MenuViewController!
    private var menuOpen: Bool = false
    public var contentVC: UIViewController! {
        didSet {
            removeInactiveViewController(inactiveViewController: oldValue)
            updateActiveViewController()
        }
    }
    
    // MARK: Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMenu()
        
        if contentVC != nil {
            updateActiveViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadMenu() {
        // load and insert menu into sidebar container
        menuVC = MenuViewController(nibName: "MenuViewController", bundle: Bundle.main)
        menuVC.delegate = self
        
        addChild(menuVC)
        menuVC.view.frame = menuContainerView.bounds
        menuContainerView.addSubview(menuVC.view)
        menuVC.didMove(toParent: self)
        
        // move menu to top
        view.bringSubviewToFront(menuContainerView)
        
        // add tap to close menu
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.closeMenu))
        shadeView.addGestureRecognizer(tap)
        
        // set current user
        menuVC.currentUser = currentUser(sender: self)
    }

    
    // MARK: Adding/removing content
    private func removeInactiveViewController(inactiveViewController: UIViewController?) {
        if let inActiveVC = inactiveViewController {
            // call before removing child view controller's view from hierarchy
            inActiveVC.willMove(toParent: nil)
            
            inActiveVC.view.removeFromSuperview()
            
            // call after removing child view controller's view from hierarchy
            inActiveVC.removeFromParent()
        }
    }
    
    private func updateActiveViewController() {
        if isViewLoaded {
            if let activeVC = contentVC {
                // call before adding child view controller's view as subview
                addChild(activeVC)
                
                activeVC.view.frame = contentContainerView.bounds
                contentContainerView.addSubview(activeVC.view)
                
                // call before adding child view controller's view as subview
                activeVC.didMove(toParent: self)
            }
        }
        
    }
    
    // MARK: Menu stuff
    @objc func openMenu() {
        menuVC.currentUser = currentUser(sender: self)
        menuOpen = true
        self.menuContainerTrailingEdge.constant = -self.menuContainerView.frame.width
        UIView.animate(withDuration: MENU_ANIM_DUR, animations: {
            self.view.layoutIfNeeded()
            self.shadeView.layer.opacity = 1.0
        })
    }
    
    @objc func closeMenu() {
        menuOpen = false
        self.menuContainerTrailingEdge.constant = 0.0
        UIView.animate(withDuration: MENU_ANIM_DUR, animations: {
                self.view.layoutIfNeeded()
                self.shadeView.layer.opacity = 0.0
        })
    }
}

extension SidebarMenuViewController: SideMenuDelegate {
    func menuItemWasSelected() {
        closeMenu()
    }
}
