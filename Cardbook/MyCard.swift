/* ------------------------------

- ContactVia -


--------------------------------*/

import UIKit
import Parse


class MyCard: UIViewController,
UIAlertViewDelegate,
UITextFieldDelegate,
UITextViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var cardView: UIView!
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var cityTxt: UITextField!
    @IBOutlet var fullNameTxt: UITextField!
    @IBOutlet var aboutTxt: UITextView!
    
    @IBOutlet var phoneTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var facebookTxt: UITextField!
    @IBOutlet var twitterTxt: UITextField!
    @IBOutlet var dribbbleTxt: UITextField!
    @IBOutlet var pinterestTxt: UITextField!
    @IBOutlet var behanceTxt: UITextField!
    @IBOutlet var youtubeTxt: UITextField!
    
    @IBOutlet var colorsScrollView: UIScrollView!
    var colorButt = UIButton()
    var bkgColor = 0
    
    
    
    /* Variables */
    var cardArray = [PFObject]()
    var cardClass = PFObject(className: CARDS_CLASS_NAME)
    
    
    

    
override func viewDidLoad() {
        super.viewDidLoad()

    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 1100)
    
    // Resize Card and Share views accordingly to the device used
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
        cardView.frame = CGRectMake(0, 0, 400, 340)
    } else {
        cardView.frame = CGRectMake(0, 0, view.frame.size.width-50, view.frame.size.width-60)
    }
    cardView.center = CGPointMake(view.frame.size.width/2, cardView.frame.size.height/2 + 10)
    
    
    // Round views corners and add a shadow
    avatarImage.layer.cornerRadius = avatarImage.bounds.size.width/2
    cardView.layer.cornerRadius = 10
    cardView.layer.shadowOffset = CGSizeMake(2, 2)
    cardView.layer.shadowOpacity = 0.8
    cardView.layer.shadowColor = superLightGray.CGColor
    
    // Setup AboutTxt placeholder
    aboutTxt.text = ABOUT_PLACEHOLDER_TEXT
    aboutTxt.textColor = UIColor.whiteColor()
    
    
    // Setup Colors menu
    setupColorsForCard()
    
    // Query data for your Card
    queryCardData()
}
    
    
// MARK: - CREATE COLOR BUTTONS TO ASSING A BACKGROUND TO YOUR CARD
func setupColorsForCard() {
    
        // Variables for setting the Buttons
        var xCoord: CGFloat = 0
        let yCoord: CGFloat = 0
        let buttonWidth:CGFloat = 44
        let buttonHeight: CGFloat = 44
        let gapBetweenButtons: CGFloat = 2
        var itemCount = 0
        
        // Loop for creating buttons ----------------------
        for i in 0..<colorsArray.count {
            itemCount = i
            colorButt = UIButton(type: UIButtonType.Custom)
            colorButt.frame = CGRectMake(xCoord, yCoord, buttonWidth, buttonHeight)
            colorButt.tag = itemCount
            colorButt.showsTouchWhenHighlighted = true
            colorButt.backgroundColor = colorsArray[itemCount]
            colorButt.addTarget(self, action: #selector(colorButtTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            // Add Buttons & Labels based on xCood
            xCoord +=  buttonWidth + gapBetweenButtons
            colorsScrollView.addSubview(colorButt)
        } // end FOR loop -----------------------------------
    
    
    // Place Buttons into the ScrollView
    colorsScrollView.contentSize = CGSizeMake(buttonWidth * CGFloat(itemCount+2), yCoord)
}
    

// MARK: - ASSIGN A BKG COLOR TO YOUR CARD (For the Cards screen)
func colorButtTapped(sender: UIButton) {
    let button = sender as UIButton
    cardView.backgroundColor = button.backgroundColor
    bkgColor = button.tag
}

    
    
    
    
// MARK: - QUERY YOUR SAVED CARD DATA
func queryCardData() {
    cardArray.removeAll()
    
    let query = PFQuery(className: CARDS_CLASS_NAME)
    query.whereKey(CARDS_USERNAME, equalTo: PFUser.currentUser()!.username!)
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            self.cardArray = objects!
            self.showCardDetails()
        
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }}
}
 
func showCardDetails() {
    cardClass = PFObject(className: CARDS_CLASS_NAME)
    cardClass = cardArray[0]
    
    // Get image
    let imageFile = cardClass[CARDS_AVATAR] as? PFFile
    imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.avatarImage.image = UIImage(data:imageData)
    }}}
    
    if cardClass[CARDS_FULLNAME] != nil {
        fullNameTxt.text = "\(cardClass[CARDS_FULLNAME]!)"
    } else { fullNameTxt.text = "" }
    
    if cardClass[CARDS_CITY] != nil {
        cityTxt.text = "\(cardClass[CARDS_CITY]!)"
    } else { cityTxt.text = ""  }

    if cardClass[CARDS_ABOUT] != nil {
        aboutTxt.text = "\(cardClass[CARDS_ABOUT]!)"
    } else { aboutTxt.text = "" }
    
    if cardClass[CARDS_EMAIL] != nil {
        emailTxt.text = "\(cardClass[CARDS_EMAIL]!)"
    } else { emailTxt.text = "" }
    
    if cardClass[CARDS_PHONE_NR] != nil {
        phoneTxt.text = "\(cardClass[CARDS_PHONE_NR]!)"
    } else { phoneTxt.text = "" }
    
    if cardClass[CARDS_FACEBOOK] != nil {
        facebookTxt.text = "\(cardClass[CARDS_FACEBOOK]!)"
    } else { facebookTxt.text = "" }
    
    if cardClass[CARDS_TWITTER] != nil {
        twitterTxt.text = "\(cardClass[CARDS_TWITTER]!)"
    } else { twitterTxt.text = "" }
    
    if cardClass[CARDS_DRIBBBLE] != nil {
        dribbbleTxt.text = "\(cardClass[CARDS_DRIBBBLE]!)"
    } else { dribbbleTxt.text = "" }
    
    if cardClass[CARDS_PINTEREST] != nil {
        pinterestTxt.text = "\(cardClass[CARDS_PINTEREST]!)"
    } else { pinterestTxt.text = "" }
  
    if cardClass[CARDS_BEHANCE] != nil {
        behanceTxt.text = "\(cardClass[CARDS_BEHANCE]!)"
    } else { behanceTxt.text = "" }
    
    if cardClass[CARDS_YOUTUBE] != nil {
        youtubeTxt.text = "\(cardClass[CARDS_YOUTUBE]!)"
    } else { youtubeTxt.text = "" }
    
    // Get bkg Color
    if cardClass[CARDS_BACKGROUND_COLOR]  != nil {
        bkgColor = cardClass[CARDS_BACKGROUND_COLOR] as! Int
        cardView.backgroundColor = colorsArray[bkgColor]
    } else { cardView.backgroundColor = superLightGray }
    
}
    
    
    
    
    
// CHANGE AVATAR BUTTON
@IBAction func changeAvatarButt(sender: AnyObject) {
    let alert = UIAlertView(title: APP_NAME,
    message: "Select Source",
    delegate: self,
    cancelButtonTitle: "Cancel",
    otherButtonTitles: "Camera",
                       "Photo Library")
    alert.show()

}
    
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    // OPEN CAMERA
    if alertView.buttonTitleAtIndex(buttonIndex) == "Camera" {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }

    // OPEN PHOTO LIBRARY
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Photo Library" {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }

        
    // LOGOUT USER
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Logout" {
        PFUser.logOut()
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
        presentViewController(loginVC, animated: true, completion: nil)
    }

    
}
// ImpagePicker delegate
func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    avatarImage.image = image
    dismissViewControllerAnimated(true, completion: nil)
}
    
    

    
    
// MARK: - SAVE/UPDATE CARD BUTTON
@IBAction func saveCardButt(sender: AnyObject) {
    
    // IT DOESN'T SAVE WITHOUT A FULL NAME AND AN EMAIL
    if fullNameTxt.text == ""  || emailTxt.text == ""  {
        simpleAlert("You must insert at least your Full Name and email address!")
    
    } else {
        showHUD()

        // Prepare all data
        cardClass[CARDS_USERNAME] = PFUser.currentUser()!.username
        cardClass[CARDS_FULLNAME] = fullNameTxt.text
        cardClass[CARDS_EMAIL] = emailTxt.text
        if cityTxt.text != ""       { cardClass[CARDS_CITY] = cityTxt.text!.uppercaseString }
        if aboutTxt.text != ""      { cardClass[CARDS_ABOUT] = aboutTxt.text }
        if phoneTxt.text != ""      { cardClass[CARDS_PHONE_NR] = phoneTxt.text }
        if facebookTxt.text != ""   { cardClass[CARDS_FACEBOOK] =  facebookTxt.text }
        if twitterTxt.text != ""    { cardClass[CARDS_TWITTER] = twitterTxt.text }
        if dribbbleTxt.text != ""   { cardClass[CARDS_DRIBBBLE] = dribbbleTxt.text }
        if pinterestTxt.text != ""  { cardClass[CARDS_PINTEREST] = pinterestTxt.text }
        if behanceTxt.text != ""    { cardClass[CARDS_BEHANCE] = behanceTxt.text }
        if youtubeTxt.text != ""      { cardClass[CARDS_YOUTUBE] = youtubeTxt.text }
        cardClass[CARDS_BACKGROUND_COLOR] = bkgColor

        // Save Image (if exists)
        if avatarImage.image != nil {
            let imageData = UIImageJPEGRepresentation(avatarImage.image!, 0.5)
            let imageFile = PFFile(name:"avatar.jpg", data:imageData!)
            cardClass[CARDS_AVATAR] = imageFile
        }
    
        // Save Card details block
        cardClass.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                self.simpleAlert("Card successfully saved/updated!")
                self.hideHUD()
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }}
    
        
        // Filter all Topics by "#"
        let tStr = aboutTxt.text as String
        let allStringsArray = tStr.componentsSeparatedByString(" ")
        var topicString = ""
    
        for topics in allStringsArray {
            let aString = "\(topics)"
            if aString.hasPrefix("#") {
                topicString = topicString.stringByAppendingString("\(topics)" )
            }
        }
        print("TOPIC STRING: \(topicString)")

        
        // Save the Topics
        var topicsArr = [PFObject]()
        let query = PFQuery(className: TOPICS_CLASS_NAME)
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                topicsArr = objects!
                
                var topicsClass = PFObject(className: TOPICS_CLASS_NAME)
                topicsClass = topicsArr[0]
                topicsClass[TOPICS_TOPIC] = topicString
                topicsClass.saveInBackgroundWithBlock { (success, error) -> Void in
                    if error == nil { print("TOPICS SAVED: \(topicString)")
                    } else { print("\(error!.localizedDescription)") }
                }
                
            } else { self.simpleAlert("\(error!.localizedDescription)")
        }}

        
    }
}


    
    
    
// MARK: - TEXTVIEW DELEGATES
func textViewDidBeginEditing(textView: UITextView) {
    if textView.text == ABOUT_PLACEHOLDER_TEXT {
        textView.text = nil
        textView.textColor = UIColor.whiteColor()
        textView.font = UIFont(name: "Giorgio", size: 11)
    }
}
func textViewDidEndEditing(textView: UITextView) {
    if textView.text.isEmpty {
        textView.text = ABOUT_PLACEHOLDER_TEXT
        textView.textColor = UIColor.whiteColor()
    }
}
    

    
// MARK: - TEXTFIELD DELEGATE
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == cityTxt      {  fullNameTxt.becomeFirstResponder()  }
    if textField == fullNameTxt  {  aboutTxt.becomeFirstResponder()     }
    if textField == emailTxt     {  phoneTxt.becomeFirstResponder()     }
    if textField == phoneTxt     {  facebookTxt.becomeFirstResponder()  }
    if textField == facebookTxt  {  twitterTxt.becomeFirstResponder()   }
    if textField == twitterTxt   {  dribbbleTxt.becomeFirstResponder()  }
    if textField == dribbbleTxt  {  pinterestTxt.becomeFirstResponder() }
    if textField == pinterestTxt {  behanceTxt.becomeFirstResponder()   }
    if textField == behanceTxt   {  youtubeTxt.becomeFirstResponder()   }
    if textField == youtubeTxt   {  youtubeTxt.resignFirstResponder()   }
    
return true
}
    
func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if textField == cityTxt { cityTxt.text!.uppercaseString }
    
    // Check iof phone number has spaces or dashes
    if textField == phoneTxt {
        if textField.text!.containsString(" ") || textField.text!.containsString("-")  || textField.text!.containsString("/")
        || textField.text!.containsString("(") || textField.text!.containsString(")") {
            simpleAlert("Phone number must not have spaces, dashes or parenthesis.\nEx: 123456789")
        }
    }
    
return true
}
    
    
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyb(sender: UITapGestureRecognizer) {
    dismissKeyb()
}

func dismissKeyb() {
    cityTxt.resignFirstResponder()
    fullNameTxt.resignFirstResponder()
    aboutTxt.resignFirstResponder()
    phoneTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
    facebookTxt.resignFirstResponder()
    twitterTxt.resignFirstResponder()
    dribbbleTxt.resignFirstResponder()
    pinterestTxt.resignFirstResponder()
    behanceTxt.resignFirstResponder()
    youtubeTxt.resignFirstResponder()
}
    
    
    
// MARK: - REFRESH BUTTON
@IBAction func refreshButt(sender: AnyObject) {
    queryCardData()
}
    
    
    
// MARK: - LOGOUT BUTTON
@IBAction func logoutButt(sender: AnyObject) {
    let alert = UIAlertView(title: APP_NAME,
    message: "Are you sure you want to logout from \(APP_NAME)?",
    delegate: self,
    cancelButtonTitle: "No",
    otherButtonTitles: "Logout")
    alert.show()
}
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
