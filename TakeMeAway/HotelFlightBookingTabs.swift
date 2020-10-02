//
//  HotelFlightBookingTabs.swift
//  TakeMeAway
//
//  Created by cro on 13/01/2019.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Coordinator
import UIKit


class HotelFlightBookingTabs: UITabBarController {
    
    // local data models
    var trip: Trip! {
        didSet {
            if isViewLoaded {
                // enable/disable buttons accordingly
                renderData()
            }
        }
    }

    var tab: Int! {
        didSet {
            if isViewLoaded {
                // enable/disable buttons accordingly
                renderData()
            }
        }
    }
    
    var user: User? {
        didSet {
            if isViewLoaded {
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().barTintColor = UIColor.TMAColors.DarkTeal
        UITabBar.appearance().tintColor = UIColor.TMAColors.LightTeal
        
        delegate = self
    }
    
    func renderData() {
        
        if let trip = trip, let tab = tab {
            
            // also switch to tab
            
            let flightBookingWebviewController = FlightBookingWebviewController()
            
            flightBookingWebviewController.trip = trip
            
            let customFlightTabBarItem:UITabBarItem = UITabBarItem(title: "Flight", image: UIImage(named: "ic2_takeoffLO")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "ic2_takeoffLO"))
            flightBookingWebviewController.tabBarItem = customFlightTabBarItem
            
            
            
            let hotelBookingWebviewController = HotelBookingWebviewController()
            hotelBookingWebviewController.trip = trip
            let customHotelTabBarItem:UITabBarItem = UITabBarItem(title: "Hotel", image: UIImage(named: "ic2_hotel")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "ic2_hotel"))
            hotelBookingWebviewController.tabBarItem = customHotelTabBarItem
            
            let viewControllerList = [ flightBookingWebviewController, hotelBookingWebviewController ]
            viewControllers = viewControllerList
            
            self.selectedIndex = tab
        }
        
    }
    
}

extension HotelFlightBookingTabs: UITabBarControllerDelegate  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let tabViewControllers = tabBarController.viewControllers, let toIndex = tabViewControllers.index(of: viewController) else {
            return false
        }
        animateToTab(toIndex: toIndex)
        return true
    }
    
    func animateToTab(toIndex: Int) {
        guard let tabViewControllers = viewControllers,
            let selectedVC = selectedViewController else { return }
        
        guard let fromView = selectedVC.view,
            let toView = tabViewControllers[toIndex].view,
            let fromIndex = tabViewControllers.index(of: selectedVC),
            fromIndex != toIndex else { return }
        
        
        // Add the toView to the tab bar view
        fromView.superview?.addSubview(toView)
        
        // Position toView off screen (to the left/right of fromView)
        let screenWidth = UIScreen.main.bounds.size.width
        let scrollRight = toIndex > fromIndex
        let offset = (scrollRight ? screenWidth : -screenWidth)
        toView.center = CGPoint(x: fromView.center.x + offset, y: toView.center.y)
        
        // Disable interaction during animation
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: {
                        // Slide the views by -offset
                        fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y)
                        toView.center = CGPoint(x: toView.center.x - offset, y: toView.center.y)
                        
        }, completion: { finished in
            // Remove the old view from the tabbar view.
            fromView.removeFromSuperview()
            self.selectedIndex = toIndex
            self.view.isUserInteractionEnabled = true
        })
    }
}
