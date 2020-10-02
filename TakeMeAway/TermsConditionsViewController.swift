//
//  TermsCondistionsViewController.swift
//  TakeMeAway
//
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim

import UIKit
import WebKit

class TermsConditionsViewController: UIViewController {
    @IBOutlet weak var webViewContainer: UIView!
    var webView: WKWebView!
    var content: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: webViewContainer.bounds)
        webViewContainer.addSubview(webView)
        if !content.isEmpty {
            let url = URL(string:content)
            webView.load(URLRequest(url: url!))
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
