//
//  LoginFormViewController.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 11/02/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit
import Eureka
import SVProgressHUD

protocol RegisterFormDelegate {
    func userDidRegister()
}

class LoginRegisterFormViewController: FormViewController {
    
    enum FormMode {
        case register
        case login
    }
    var topLayoutConstraint: NSLayoutConstraint?
    var containerView: UIView?
    let formMode: FormMode
    
    init(formMode: FormMode = .register, style: UITableView.Style = .grouped) {
        self.formMode = formMode
        
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.formMode = .register
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create form
        let section1 = Section()
        if formMode == .register {
            section1 <<< NameRow("full_name") {
                $0.title = "Name"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChangeAfterBlurred
            }
        }
        section1 <<< EmailRow("email") {
                $0.title = "Email"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChangeAfterBlurred
            }
            <<< PasswordRow("password") {
                $0.title = "Password"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChangeAfterBlurred
            }
        
        let section2 = Section()
        if formMode == .register {
            section2 <<< ButtonRow() {
                $0.title = "Register"
                }
            .onCellSelection { cell, row in
                let errors = row.section?.form?.validate()
                if errors?.count == 0 {
                    // success
                    SVProgressHUD.show()
                    let data = self.form.values()
                    self.registerWithCredentials(sender: self, name: data["full_name"] as! String, email: data["email"] as! String, password: data["password"] as! String, completion: { (success) in
                        if success {
                            SVProgressHUD.showSuccess(withStatus: nil)
                            self.didLogin(sender: self)
                            self.dismissLoginRegister(sender: self)
                        } else {
                            SVProgressHUD.showError(withStatus: "Registration failed")
                        }
                    })
                } else {
                    SVProgressHUD.showError(withStatus: "Missing info!")
                }
            }
        } else {
            section2 <<< ButtonRow() {
                $0.title = "Login"
                }
                .onCellSelection { cell, row in
                    let errors = row.section?.form?.validate()
                    if errors?.count == 0 {
                        // success
                        SVProgressHUD.show()
                        let data = self.form.values()
                        self.loginWithCredentials(sender: self, username: data["email"] as! String, password: data["password"] as! String, completion: { (success) in
                            if success {
                                SVProgressHUD.showSuccess(withStatus: nil)
                                // switch to destinations
                                self.didLogin(sender: self)
                                self.dismissLoginRegister(sender: self)
                            } else {
                                SVProgressHUD.showError(withStatus: "Login failed")
                            }
                        })
                    } else {
                        SVProgressHUD.showError(withStatus: "Missing info!")
                    }
                }
                <<< ButtonRow() {
                    $0.title = "Cancel"
                }.onCellSelection { cell, row in
                    self.dismissLoginRegister(sender: self)
                }
        }
        
        // append sections to form
        form +++ section1 +++ section2
    }
    
    @objc func userDidTapFiltersButton(sender: Any?) {
        self.accountShowPage(AccountPageBox(.filters), sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        super.keyboardWillShow(notification)
        
        topLayoutConstraint?.constant = -100
        UIView.animate(withDuration: 0.6, animations: {() in
            self.containerView?.layoutIfNeeded()
        })
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        super.keyboardWillHide(notification)
        
        topLayoutConstraint?.constant = 0
        UIView.animate(withDuration: 0.6, animations: {() in
            self.containerView?.layoutIfNeeded()
        })
    }
}
