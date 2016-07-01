/* ------------------------------

- ContactVia -


--------------------------------*/

import UIKit
import Parse
import Social
import MessageUI
import GoogleMobileAds
import AudioToolbox


class CardDetails: UIViewController,
UITextViewDelegate,
UIAlertViewDelegate,
MFMailComposeViewControllerDelegate,
GADBannerViewDelegate
{

    /* Views */
    @IBOutlet var cardView: UIView!
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var fullNameLabel: UILabel!
    @IBOutlet var aboutTxt: UITextView!
    
    @IBOutlet var favStar: UIImageView!
    
    @IBOutlet var addToFavOutlet: UIButton!
    @IBOutlet var confirmLabel: UILabel!
    @IBOutlet var shareView: UIView!
    
    var reportButt = UIButton()
    
    // Ad banners properties
    var adMobBannerView = GADBannerView()
    
    
    
    /* Variables */
    var cardObj = PFObject(className: CARDS_CLASS_NAME)
    var cardToBeShared = UIImage()
    var favArray = [PFObject]()
    
    
    // Array of string for Contact links
    var linksArray = NSMutableArray()
    var fbStr = ""
    var twStr = ""
    var drStr = ""
    var pnStr = ""
    var bhStr = ""
    var ytStr = ""
    var phoneStr = ""
    var emailStr = ""
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Set Title
    self.title = "Card Details"
    
    confirmLabel.alpha = 0
    
    // Initialize ad banners
    initAdMobBanner()
    
    
    // Initialize a Report Button
    reportButt = UIButton(type: UIButtonType.Custom)
    reportButt.adjustsImageWhenHighlighted = false
    reportButt.frame = CGRectMake(0, 0, 44, 44)
    reportButt.setBackgroundImage(UIImage(named: "reportButt"), forState: UIControlState.Normal)
    reportButt.addTarget(self, action: #selector(reportButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportButt)
    
    
    // Resize Card and Share views accordingly to the device used
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
        cardView.frame = CGRectMake(0, 0, 450, 400)
        shareView.frame = CGRectMake(0, 0, 450, 64)
    } else {
        cardView.frame = CGRectMake(0, 0, view.frame.size.width-50, view.frame.size.width-60)
        shareView.frame = CGRectMake(0, 0, view.frame.size.width-50, 64)
    }
    
    // Position Card and Share views on the screen
    cardView.center = view.center
    shareView.center = view.center
    addToFavOutlet.frame.origin.y = cardView.frame.origin.y + cardView.frame.size.height + 10
    
    // Round views corners and add a shadow
    avatarImage.layer.cornerRadius = avatarImage.bounds.size.width/2
    addToFavOutlet.layer.cornerRadius = 20
    cardView.layer.cornerRadius = 10
    cardView.layer.shadowOffset = CGSizeMake(2, 2)
    cardView.layer.shadowOpacity = 0.8
    cardView.layer.shadowColor = superLightGray.CGColor
    confirmLabel.layer.cornerRadius = 6
    shareView.layer.cornerRadius = 10
    

    
    // Create a back button for the navigationBar
    let prevButt = UIButton(type: UIButtonType.Custom)
    prevButt.frame = CGRectMake(0, 0, 44, 44)
    prevButt.setBackgroundImage(UIImage(named: "backButt"), forState: UIControlState.Normal)
    prevButt.addTarget(self, action: #selector(backButt(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: prevButt)
    navigationItem.leftBarButtonItem?.tintColor = mediumGray
    
    checkLinks()
    
    // Show card's dedatils
    showCardDetails()
}
    
    
func showCardDetails() {
    // Get card's details
    let imageFile = cardObj[CARDS_AVATAR] as? PFFile
    imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
        if error == nil {
          if let imageData = imageData {
            self.avatarImage.image = UIImage(data:imageData)
    } } }
    
    // Get other details
    cityLabel.text = "\(cardObj[CARDS_CITY]!)"
    fullNameLabel.text = "\(cardObj[CARDS_FULLNAME]!)"
    aboutTxt.text = "\(cardObj[CARDS_ABOUT]!)"
    
    // Get bkg Color
    let bkgColor = cardObj[CARDS_BACKGROUND_COLOR] as! Int
    cardView.backgroundColor = colorsArray[bkgColor]
    

    
    
    // MAKE A QUERY IN BACKGROUND TO CHECK IF THIS CARD IS IN YOUR FAVORITES
    favArray.removeAll()
    let query = PFQuery(className: FAVORITES_CLASS_NAME)
    query.whereKey(FAVORITES_CURRENT_USER, equalTo: PFUser.currentUser()!)
    query.whereKey(FAVORITES_CARD, equalTo: cardObj)
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            self.favArray = objects!
            
            if self.favArray.count != 0 {
                self.showFavStar()
            }
        } else { print("\(error!.description)")
    }}
}

// MARK: - SHOW FAV STAR ON CARD (IF IT'S IN YOUR FAVORITES)
func showFavStar() {
    favStar.hidden = false
    addToFavOutlet.hidden = true
    shareView.frame.origin.y = cardView.frame.origin.y + cardView.frame.size.height - 23
}
    

    
// MARK: - CHECK CONTACT LINKS OF THE SELECTED CARD
func checkLinks() {
        linksArray.removeAllObjects()
        
        if cardObj[CARDS_EMAIL] != nil  {
            emailStr = "\(cardObj[CARDS_EMAIL]!)"
            linksArray.addObject("Mail")
        }
        if cardObj[CARDS_PHONE_NR] != nil  {
            phoneStr = "\(cardObj[CARDS_PHONE_NR]!)"
            linksArray.addObject("Phone")
        }
        if cardObj[CARDS_FACEBOOK] != nil  {
            fbStr = "\(cardObj[CARDS_FACEBOOK]!)"
            linksArray.addObject("Facebook")
        }
        if cardObj[CARDS_TWITTER] != nil   {
            twStr = "\(cardObj[CARDS_TWITTER]!)"
            linksArray.addObject("Twitter")
        }
        if cardObj[CARDS_DRIBBBLE] != nil  {
            drStr = "\(cardObj[CARDS_DRIBBBLE]!)"
            linksArray.addObject("Dribbble")
        }
        if cardObj[CARDS_PINTEREST] != nil  {
            pnStr = "\(cardObj[CARDS_PINTEREST]!)"
            linksArray.addObject("Pinterest")
        }
        if cardObj[CARDS_BEHANCE] != nil  {
            bhStr = "\(cardObj[CARDS_BEHANCE]!)"
            linksArray.addObject("Behance")
        }
        if cardObj[CARDS_YOUTUBE] != nil  {
            ytStr = "\(cardObj[CARDS_YOUTUBE]!)"
            linksArray.addObject("YouTube")
        }
        print("\(linksArray)")
}
    
    
    
// MARK: - ADD THIS CARD TO YOUR FAVORITES BUTTON
@IBAction func addToFavButt(sender: AnyObject) {
    // Save the Card as Pointer
    let favClass = PFObject(className: FAVORITES_CLASS_NAME)
    favClass[FAVORITES_CARD] = cardObj
    favClass[FAVORITES_CURRENT_USER] = PFUser.currentUser()
    
    favClass.saveInBackgroundWithBlock {(success, error) -> Void in
        if error == nil {
            print("CARD SAVED TO FAVORITES!")
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }}
    
    
    
    UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
        self.addToFavOutlet.alpha = 0
        self.addToFavOutlet.frame.origin.y = self.view.frame.size.height
        
        self.shareView.frame.origin.y = self.cardView.frame.origin.y + self.cardView.frame.size.height - 23
        
    }, completion: { (finished: Bool) in
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.confirmLabel.alpha = 1
            self.confirmLabel.frame.origin.y = self.view.frame.size.height/2
        }, completion: { (finished: Bool) in  })
    
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.hideConfirmLabel), userInfo: nil, repeats: false)
    })
}

func hideConfirmLabel() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.confirmLabel.frame.origin.y = -self.confirmLabel.frame.size.height
        self.confirmLabel.alpha = 0
    }, completion: { (finished: Bool) in  })
}
    

    
    
    
// MARK: - SHARE CARD ON FACEBOOK
@IBAction func facebookButt(sender: AnyObject) {
    getCardImage()
    
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
        let fbSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        fbSheet.setInitialText("Sharing an interesting Card I've seen on #\(APP_NAME)")
        fbSheet.addImage(cardToBeShared)
        presentViewController(fbSheet, animated: true, completion: nil)
    } else {
        let alert: UIAlertView = UIAlertView(title: "Facebook",
        message: "Please login to your Facebook account in Settings",
        delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
}

    
    
// MARK: - SHARE CARD ON TWITTER
@IBAction func twitterButt(sender: AnyObject) {
    getCardImage()
    
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
        let twSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        twSheet.setInitialText("Sharing an interesting Card I've seen on #\(APP_NAME)")
        twSheet.addImage(cardToBeShared)
        presentViewController(twSheet, animated: true, completion: nil)
    } else {
        let alert: UIAlertView = UIAlertView(title: "Twitter",
        message: "Please login to your Twitter account in Settings",
        delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
}
    


// Crop a Combined Image with the size of the shareView
func getCardImage() {
    let rect = cardView.bounds
    UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
    cardView.drawViewHierarchyInRect(cardView.bounds, afterScreenUpdates: false)
    cardToBeShared = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
}
    
    
    
// MARK: - BACK BUTTON
func backButt(sender:UIButton) {
    navigationController?.popViewControllerAnimated(true)
}
  
    
    
    
// MARK: - TEXTVIEW DELEGATE
func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
    // Check for our fake URL scheme hash:helloWorld
    if let scheme:String = URL.scheme {
        switch scheme {
            case "hash" :  makeSearch(URL.resourceSpecifier)
            break
            default: print("Regular url"); break
        }
    }
        
return true
}

func makeSearch(payload:String){
    let cardsVC = storyboard?.instantiateViewControllerWithIdentifier("Cards") as! Cards
    cardsVC.hashtagStr = payload
    navigationController?.popViewControllerAnimated(true)
}


    
    
    
// MARK: - CONTACT USER BUTTON
@IBAction func contactButt(sender: AnyObject) {
    // Show AlertView with Contact links
    let alert = UIAlertView(title: APP_NAME,
        message: "Contact \(cardObj[CARDS_FULLNAME]!)",
        delegate: self,
        cancelButtonTitle: "Cancel")
    
    // Get Button titles from the linksArray
    for aTitle in linksArray {
        alert.addButtonWithTitle(aTitle as? String)
    }
    alert.show()
}
    
// AlertView delegate (open contact links
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    var aURL = NSURL()
    let currentUser = PFUser.currentUser()
    let currUsername = currentUser?.objectForKey(USER_USERNAME) as! String
    
    // Send Email
    if alertView.buttonTitleAtIndex(buttonIndex) == "Mail" {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject("Message from \(currUsername)")
        mailComposer.setMessageBody("Hello, \(cardObj[CARDS_FULLNAME]!)\n", isHTML: true)
        mailComposer.setToRecipients(["\(cardObj[CARDS_EMAIL]!)"])
        presentViewController(mailComposer, animated: true, completion: nil)
        
    // Open call screen
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Phone" {
        aURL = NSURL(string: "telprompt://\(cardObj[CARDS_PHONE_NR]!)")!
        if UIApplication.sharedApplication().canOpenURL(aURL) {
            UIApplication.sharedApplication().openURL(aURL)
        }
        
    // Open Facebook
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Facebook" {
        aURL = NSURL(string: fbStr)!
        UIApplication.sharedApplication().openURL(aURL)
    
    // Open twitter
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Twitter" {
        aURL = NSURL(string: twStr)!
        UIApplication.sharedApplication().openURL(aURL)
    
    // Open Dribbble
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Dribbble" {
        aURL = NSURL(string: drStr)!
        UIApplication.sharedApplication().openURL(aURL)
    
    // Open Pinterest
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Pinterest" {
    aURL = NSURL(string: pnStr)!
    UIApplication.sharedApplication().openURL(aURL)
    
    // Open Behance
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Behance" {
        aURL = NSURL(string: bhStr)!
        UIApplication.sharedApplication().openURL(aURL)
        
    // Open YouTube
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "YouTube" {
    aURL = NSURL(string: ytStr)!
    UIApplication.sharedApplication().openURL(aURL)
    }
}
    
    

    
// MARK: - REPORT AD BUTTON
func reportButton(sender:UIButton) {
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setToRecipients([MY_REPORT_EMAIL_ADDRESS])
    mailComposer.setSubject("Reporting Inappropriate Card")
    mailComposer.setMessageBody("Hello,<br>I am reporting a Card of User named: <strong>\(cardObj[CARDS_FULLNAME]!)</strong><br>Card ID: <strong>\(cardObj.objectId!)</strong><br>since it contains inappropriate contents and violates the Terms of Use of this App.<br><br>Please moderate or remove this Card.<br><br>Thank you very much,<br>Regards.", isHTML: true)
        
    presentViewController(mailComposer, animated: true, completion: nil)
}

// Email delegate
func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        var outputMessage = ""
    switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue: outputMessage = "Mail cancelled"
        case MFMailComposeResultSaved.rawValue: outputMessage = "Mail saved"
        case MFMailComposeResultSent.rawValue: outputMessage = "Mail sent"
        case MFMailComposeResultFailed.rawValue: outputMessage = "Something went wrong with sending Mail, try again later."
        default: break
    }
    
    simpleAlert(outputMessage)
    dismissViewControllerAnimated(false, completion: nil)
}


    


    


    
// MARK: - AdMob BANNER METHODS */
func initAdMobBanner() {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSizeMake(320, 50))
        adMobBannerView.frame = CGRectMake(0, -50, 320, 50)

        adMobBannerView.adUnitID = ADMOB_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        
        let request = GADRequest()
        adMobBannerView.loadRequest(request)
    }
    
    
    // Hide the banner
    func hideBanner(banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        // Hide the banner moving it below the bottom of the screen
        banner.frame = CGRectMake(0, -banner.frame.size.height, banner.frame.size.width, banner.frame.size.height)
        UIView.commitAnimations()
        banner.hidden = true
        
    }
    
    // Show the banner
    func showBanner(banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        
        // Move the banner on the top of the screen
        banner.frame = CGRectMake(view.frame.size.width/2 - banner.frame.size.width/2, 64, banner.frame.size.width, banner.frame.size.height)
        UIView.commitAnimations()
        banner.hidden = false
        
    }
    
    // AdMob banner available
    func adViewDidReceiveAd(view: GADBannerView!) {
        print("AdMob loaded!")
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
    }
    

 
    

    

override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
