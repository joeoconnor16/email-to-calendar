//
//  AccountViewController.swift
//  email-to-calendar
//
//  Created by Joseph OConnor on 4/22/18.
//  Copyright © 2018 Joseph OConnor. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    @IBOutlet var logInButton: UIButton!
    let service = OutlookService.shared()
    
    func setLogInState(loggedIn: Bool) {
        if (loggedIn) {
            logInButton.setTitle("Log Out", for: UIControlState.normal)
        }
        else {
            logInButton.setTitle("Log In", for: UIControlState.normal)
        }
    }
    
    @IBAction func logInButtonTapped(sender: AnyObject) {
        if (service.isLoggedIn) {
            // Logout
            service.logout()
            setLogInState(loggedIn: false)
        } else {
            // Login
            service.login(from: self) {
                error in
                if let unwrappedError = error {
                    NSLog("Error logging in: \(unwrappedError)")
                } else {
                    NSLog("Successfully logged in.")
                    self.setLogInState(loggedIn: true)
                    self.loadUserData()
                }
            }
        }
    }
    
    func loadUserData() {
        service.getUserEmail() {
            email in
            if let unwrappedEmail = email {
                NSLog("Hello \(unwrappedEmail)")
                self.service.getInboxMessages(){
                    messages in
                    if let unwrappedMessages = messages {
                        for (message) in unwrappedMessages["value"].arrayValue {
                            NSLog(message["subject"].stringValue)
                            NSLog(message["from"]["emailAddress"]["address"].stringValue)
                            NSLog(message["body"]["content"].stringValue)
                        }
                    }
                }
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setLogInState(loggedIn: service.isLoggedIn)
        if (service.isLoggedIn) {
            loadUserData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

