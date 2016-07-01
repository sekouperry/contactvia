/* ------------------------------

- ContactVia -


--------------------------------*/

import UIKit
import Parse


class Login: UIViewController,
UITextFieldDelegate,
UIAlertViewDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    
    @IBOutlet var logo: UIImageView!
    
override func viewWillAppear(animated: Bool) {
    if PFUser.currentUser() != nil {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round views corners
        logo.layer.cornerRadius = 20
        
        containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 600)
        
        navigationController?.navigationBarHidden = true
}
    
    
// MARK: - LOGIN BUTTON
@IBAction func loginButt(sender: AnyObject) {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
    showHUD()
    
    PFUser.logInWithUsernameInBackground(usernameTxt.text!, password:passwordTxt.text!) {
        (user, error) -> Void in
            
        if user != nil { // Login successfull
            self.dismissViewControllerAnimated(true, completion: nil)
            self.hideHUD()
            
        } else { // Login failed. Try again or SignUp
            let alert = UIAlertView(title: APP_NAME,
                message: "\(error!.localizedDescription)",
                delegate: self,
                cancelButtonTitle: "Retry",
                otherButtonTitles: "Sign Up")
                alert.show()

                self.hideHUD()
    }}
    
}
    
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if alertView.buttonTitleAtIndex(buttonIndex) == "Sign Up" {
        signupButt(self)
    }
        
    if alertView.buttonTitleAtIndex(buttonIndex) == "Reset Password" {
        PFUser.requestPasswordResetForEmailInBackground("\(alertView.textFieldAtIndex(0)!.text!)")
        showNotifAlert()
    }
}
    
    
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(sender: AnyObject) {
    let signupVC = self.storyboard?.instantiateViewControllerWithIdentifier("Signup") as! Signup
    presentViewController(signupVC, animated: true, completion: nil)
}
    
    
    
    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == usernameTxt { passwordTxt.becomeFirstResponder() }

    if textField == passwordTxt  {
        loginButt(self)
        passwordTxt.resignFirstResponder()
    }
    
return true
}
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(sender: UITapGestureRecognizer) {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
}
    
    
// MARK: - FORGOT PASSWORD BUTTON
@IBAction func forgotPasswButt(sender: AnyObject) {
    let alert = UIAlertView(title: APP_NAME,
    message: "Type your email address you used to register.",
    delegate: self,
    cancelButtonTitle: "Cancel",
    otherButtonTitles: "Reset Password")
    alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
    alert.show()
}
    
    
// MARK: - NOTIFICATION ALERT FOR PASSWORD RESET
func showNotifAlert() {
    let alert = UIAlertView(title: APP_NAME,
    message: "You will receive an email shortly with a link to reset your password",
    delegate: nil,
    cancelButtonTitle: "OK")
    alert.show()
}
    

    
// MARK: - SHOW TERMS OF USE
@IBAction func termsOfUseButt(sender: AnyObject) {
    let touVC = self.storyboard?.instantiateViewControllerWithIdentifier("TermsOfUse") as! TermsOfUse
    presentViewController(touVC, animated: true, completion: nil)
}

    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
