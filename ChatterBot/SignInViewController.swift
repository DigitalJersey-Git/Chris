//
//  ViewController.swift
//  ChatterBot
//
//  Created by Chris Mousdale on 23/02/2017.
//  Copyright © 2017 Chris Mousdale. All rights reserved.
//

import UIKit
import SendBirdSDK

class SignInViewController: UIViewController {
    
    var userID: String?
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        signInButton!.layer.cornerRadius = 8
        self.userID = defaults.string(forKey: "userID")
        let userName = defaults.string(forKey: "username")
        print("read: \(self.userID) - \(userName)")
        usernameTextField.text = userName
    }

    
    func randomString(_ length: Int) -> String? {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    @IBAction func signInAction(_ sender: UIButton) {
        if usernameTextField.text != "" {
            
            // Don't want to ser the userID again if we already have one.
            if self.userID == nil {
                self.userID = usernameTextField.text! + "-"
                
                if let randomS = randomString(10) {
                    self.userID?.append(randomS)
                }
                
                defaults.set(self.userID, forKey: "userID")
                defaults.set(usernameTextField.text, forKey: "username")
                defaults.synchronize()
            }
            
            if let userid = self.userID, let username = usernameTextField.text {
                
                // Connect to sendbird.
                SBDMain.connect(withUserId: userid, completionHandler: { [unowned self]
                    (user, error) in
                    
                    // Display error and return if it could not get any data from the service.
                    if error != nil {
                        let vc = UIAlertController(title: "Error", message: "Problem creating channel", preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action) in
                            self.dismiss(animated: false, completion: nil)
                        })
                        vc.addAction(closeAction)
                        DispatchQueue.main.async {
                            self.present(vc, animated: true, completion: nil)
                        }
                        return;
                    }
                    
                    // Update the user name and profile.
                    SBDMain.updateCurrentUserInfo(withNickname: username, profileImage: nil, completionHandler: { (error) in
                        // Not checking anything here.
                    })
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "signInSegue", sender: self)
                    }
                })
            }
            
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please enter a username before proceeding", preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in
                //self.pressed()
            })
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    


}

