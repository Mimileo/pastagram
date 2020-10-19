//
//  LoginViewController.swift
//  pastagram
//
//  Created by Mireya Leon on 10/6/20.
//  Copyright © 2020 mireyaleon76. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

  
    @IBAction func onSignIn(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil {
               
                print("Siging in...")
                 //self.performSegue(withIdentifier: "loginSegue", sender: nil)
                
                
                let main = UIStoryboard(name: "Main", bundle: nil)
                //let tabBarController = main.instantiateViewController(withIdentifier: "tabBarControllerIdentifier")

                let feedViewController = main.instantiateViewController(withIdentifier: "FeedNavigationController")
                       
                print(UIApplication.shared.connectedScenes)
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                         let delegate = windowScene.delegate as? SceneDelegate
                       else {
                         return
                       }
                       
                      // let delegate = UIApplication.shared.delegate as! AppDelegate
                       
                       delegate.window?.rootViewController = feedViewController
                
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
        
        
    
    }
    
    
    @IBAction func onSignup(_ sender: Any) {
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
               
        user.signUpInBackground{ (success, error) in
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
