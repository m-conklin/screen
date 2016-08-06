//
//  LoginViewController.swift
//  personality
//
//  Created by Martin Conklin on 2016-08-04.
//  Copyright © 2016 Martin Conklin. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import CoreData

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    let facebook = FacebookHandler.sharedInstance
    let managedObjectContext = FacebookHandler.sharedInstance.managedObjectContext
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hasCurrentToken = FacebookHandler.sharedInstance.facebookToken()
        
        if hasCurrentToken {
            facebook.returnUserData()
        } else {
            loginButton.readPermissions = ["public_profile", "email", "user_friends", "ads_read", "user_birthday", "user_location", "user_likes", "user_posts", "user_religion_politics", "user_about_me", "user_education_history", "user_hometown", "user_photos"]
            loginButton.delegate = facebook
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func userTestButton(sender: UIButton) {
        var userArray: [User]?
        let fetchRequest = NSFetchRequest(entityName: "User")
        do {
            userArray = try managedObjectContext.executeFetchRequest(fetchRequest) as? [User]
        } catch let getUserError as NSError {
            print("Error fetching User: \(getUserError)")
        }
        let user = userArray![0]
        
        
        for item in user.posts! {
            print(item.message)
        }
        
        let cognito = CognitoHandler()
        cognito.loginToCognito()
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        loginButton.delegate = nil
        print("Did prepare for segue")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
