//
//  LoginRegisterViewController.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 17/12/2017.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit
import FacebookLogin
import TwitterKit
import SVProgressHUD

class LoginRegisterViewController: UIViewController {

    @IBOutlet weak var loginButtonStackView: UIStackView!
    @IBOutlet weak var formContainer: UIView!
    @IBOutlet weak var formContainerTopConstraint: NSLayoutConstraint!
    
    let formVC: LoginRegisterFormViewController
    var facebookButton: LoginButton!
    var twitterButton: TWTRLogInButton!
    
    init(formMode: LoginRegisterFormViewController.FormMode, nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.formVC = LoginRegisterFormViewController(formMode: formMode, style: .grouped)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.formVC = LoginRegisterFormViewController(formMode: .register, style: .grouped)
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addChild(formVC)
        formVC.view.frame = formContainer.bounds
        formVC.topLayoutConstraint = formContainerTopConstraint
        formVC.containerView = self.view
        formContainer.addSubview(formVC.view)
        formVC.didMove(toParent: self)
        
        // set up facebook button
        facebookButton = LoginButton(readPermissions: [.publicProfile, .email])
        facebookButton.delegate = self
        loginButtonStackView.addArrangedSubview(facebookButton)
        
        // twitter login button
        // TODO: check why the session is not recognized as nil
        twitterButton = TWTRLogInButton(logInCompletion: { session, error in
            if let session = session {
                
                let token = session.authToken
                let userId = session.userName
                
                SVProgressHUD.show()
                self.twitterCompletedLogin(userId: userId, token: token, sender: self, completion: {(success) in
                    if success {
                        // go to destinations page
                        SVProgressHUD.showSuccess(withStatus: nil)
                        self.didLogin(sender: self)
                        self.dismissLoginRegister(sender: self)
                    } else {
                        // show error
                        SVProgressHUD.showError(withStatus: "Unable to complete login")
                    }
                })
            } else {
                
                self.alertWithTitle("Error", message: error!.localizedDescription)
                print("error: \(error!.localizedDescription)");
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertWithTitle(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension LoginRegisterViewController: LoginButtonDelegate {
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .success(_, _, let token):
            
            guard let userId = token.userId else {
                SVProgressHUD.showError(withStatus: "Error completing Facebook login")
                return
            }
            
            // got token, now go and do login to our api
            SVProgressHUD.show()
            facebookCompletedLogin(userId: userId, token: token.authenticationToken, sender: self, completion: {(success) in
                if success {
                    SVProgressHUD.showSuccess(withStatus: nil)
                    self.didLogin(sender: self)
                    self.destinationShowPage(DestinationPageBox.init(.chooseDestination), sender: self)
                } else {
                    SVProgressHUD.showError(withStatus: "Error completing Facebook login")
                }
                
            })
            
        case .failed(let error):
            // TODO: handle this better?
            SVProgressHUD.showError(withStatus: "Error completing Facebook login: \(error)")
            
        case .cancelled:
            // do nothing
            break
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        // do we care?
    }
    
    
}
