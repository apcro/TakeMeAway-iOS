//
//  HotelBookingWebview.swift
//  TakeMeAway
//
//  Created by cro on 13/01/2019.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import UIKit
import WebKit

class FlightBookingWebviewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    private var loadingObservation: NSKeyValueObservation?
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = UIColor.TMAColors.DarkTeal
        return spinner
    }()
    
    // local data models
    var trip: Trip! {
        didSet {
            if isViewLoaded {
            }
        }
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingObservation = webView.observe(\.isLoading, options: [.new, .old]) { [weak self] (_, change) in
            guard let strongSelf = self else { return }
            
            // this is fine
            let new = change.newValue!
            let old = change.oldValue!
            
            if new && !old {
                strongSelf.view.addSubview(strongSelf.loadingIndicator)
                strongSelf.loadingIndicator.startAnimating()
                NSLayoutConstraint.activate([strongSelf.loadingIndicator.centerXAnchor.constraint(equalTo: strongSelf.view.centerXAnchor),
                                             strongSelf.loadingIndicator.centerYAnchor.constraint(equalTo: strongSelf.view.centerYAnchor)])
                strongSelf.view.bringSubviewToFront(strongSelf.loadingIndicator)
            }
            else if !new && old {
                strongSelf.loadingIndicator.stopAnimating()
                strongSelf.loadingIndicator.removeFromSuperview()
            }
        }
        
        if let trip = trip {
            if let desturi = trip.destination.flightRefUri {
                let url = URL(string: desturi)
                let defaultUrl = URL(string: "https://www.skyscanner.com")
                webView.load(URLRequest(url: url ?? defaultUrl!))
            } else {
                webView.load(URLRequest(url: URL(string: "https://www.skyscanner.com")!))
            }
        }
        
        
    }
    
}


