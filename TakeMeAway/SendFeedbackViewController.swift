//
//  SendFeedbackViewController.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 17/12/2017.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit
import SVProgressHUD

class SendFeedbackViewController: UIViewController {
    
    let KEYB_SHIFT_AMT: CGFloat = 50.0
    let ANIM_DURATION = 0.6
    var hasEdited = false

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBAction func userDidPressSendButton(_ sender: Any) {
        SVProgressHUD.show()
        submitFeedback(sender: self, feedback: textView.text, completion: {(error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error.debugDescription)
            } else {
                SVProgressHUD.showSuccess(withStatus: "Feedback sent!")
                self.resetTextView()
                self.dismissHelp(sender: self)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textView.delegate = self
        textView.textColor = .gray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        sendButton.isEnabled = false
        
        // set font family for all my view's subviews
        setFontFamilyForView("Muli-Regular", view: view, andSubviews: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkMessageValid(_ message: String) -> Bool {
    
        let result =  !message.isEmpty
        
        // TODO: set some rules for approving message
        
        return result
    }
    
    func moveViewsForKeyboard(Visible visible: Bool) {
        var yShift: CGFloat
        if visible
        {
            // move views up a touch
            yShift = -KEYB_SHIFT_AMT
        }
        else
        {
            // move them back to original position
            yShift = KEYB_SHIFT_AMT
        }
        
        UIView.animate(withDuration: ANIM_DURATION, animations: {
            self.textView.center.y += yShift
            self.sendButton.center.y += yShift
        })
    }
    
    @objc func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    
    func resetTextView() {
        hasEdited = false
        textView.textColor = .gray
        textView.text = "Please type feedback here"
    }

}

extension SendFeedbackViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !hasEdited {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        // replace empty text with placeholder if necessary
        if textView.text.isEmpty {
            resetTextView()
        } else {
            hasEdited = true
        }
        
        // enable button if we have valid feedback to send
        if hasEdited && checkMessageValid(textView.text) {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
    }
}
