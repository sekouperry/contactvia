/* ------------------------------

- ContactVia -


--------------------------------*/

import UIKit
import Parse


class Signup: UIViewController,
UITextFieldDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    
    @IBOutlet var logo: UIImageView!
    
    
override func viewDidLoad() {
        super.viewDidLoad()
        
    // Round views corners
    logo.layer.cornerRadius = 20
        
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 600)
    
    navigationController?.navigationBarHidden = true
}
    

    
// MARK: - BACK BUTTON
@IBAction func backButt(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
}
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(sender: UITapGestureRecognizer) {
    dismissKeyboard()
}
    
func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
}
    
   
    
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(sender: AnyObject) {
    dismissKeyboard()
    showHUD()

    let userForSignUp = PFUser()
    
    if usernameTxt.text != "" && passwordTxt != "" && emailTxt != "" {
    
        userForSignUp.username = usernameTxt.text
        userForSignUp.password = passwordTxt.text
        userForSignUp.email = emailTxt.text
        
    
        userForSignUp.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
            if error == nil { // Successful Signup
                self.dismissViewControllerAnimated(true, completion: nil)
                self.hideHUD()
                
            } else { // No signup, something went wrong
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }}
    
        
    // ALL FIELDS MUST NOT BE EMPTY
    } else {
        self.simpleAlert("You must set a username, a password and an email adress to Sign Up")
        self.hideHUD()
    }
    
}
    

    
// MARK: -  TEXTFIELD DELEGATE */
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == usernameTxt {   passwordTxt.becomeFirstResponder()  }
    if textField == passwordTxt {  emailTxt.becomeFirstResponder()  }
    if textField == emailTxt {   emailTxt.resignFirstResponder()   }
        
return true
}
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
