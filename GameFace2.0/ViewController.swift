//
//  ViewController.swift
//  GameFace2.0
//
//  Created by Eric.Fox on 3/24/18.
//  Copyright © 2018 GameFace, LLC. All rights reserved.
//

import UIKit
import AppTrackingTransparency

class ViewController: UIViewController {
    
    @IBOutlet weak var homeScreenLogo: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let rippleLayer = RippleLayer()
        rippleLayer.position = CGPoint(x: self.view.layer.bounds.midX, y: self.view.layer.bounds.midY);
        
        self.view.layer.insertSublayer(rippleLayer, below: homeScreenLogo.layer)
        rippleLayer.startAnimation()
        
//        _ = Timer.scheduledTimer(timeInterval: 4.5, target: self, selector: #selector(segueToSignIn), userInfo: nil, repeats: false)
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 
        if #available(iOS 14, *) {
          ATTrackingManager.requestTrackingAuthorization { (status) in }
        } 
    }
    
    
    @IBAction func `switch`(_ sender: UISwitch) {
        if  (sender.isOn == true)
        {
            DispatchQueue.main.asyncAfter(deadline:.now() + 1.75, execute: {
            self.performSegue(withIdentifier: "segue1", sender: self)
            })
            
        }
        else
            {
                print("I do not agree to Terms-of-Use")
           
    }
        }
    
override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
        
    }



























//    // Facebook Log in
//    @IBAction func btnLoginWithFacebookTapped(_ sender: Any) {
//        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
//        fbLoginManager.logIn(withReadPermissions: ["email"], from: self){ (result, error) in
//            if (error == nil){
//                let fbLoginresult: FBSDKLoginManagerLoginResult = result!
//                if fbLoginresult.grantedPermissions != nil{
//                    if(fbLoginresult.grantedPermissions.contains("email")) {
//                }
//            }
//        }
//    }
//
//
//}
//    //Mark Facebook Delegate
//    func loginButtonDidLogout(_ loginButton: FBSDKLoginButton!)
//    {
//        print("user logout")
//    }
//    func GetFBUserData(){
//        if((FBSDKAccessToken.current()) != nil){
//            FBSDKGraphRequest(graphPath: "me", parameters: ["field":"id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler:{(connection, result, error) -> Void in
//                if (error == nil) {
//                    let faceDic = result as! [String:AnyObject]
//                    print(faceDic)
//                    let email = faceDic["email"] as! String
//                    print(email)
//                    let id = faceDic["id"] as! String
//                    print(id)
//                }
//
//                })
//
//        }
//    }



}
