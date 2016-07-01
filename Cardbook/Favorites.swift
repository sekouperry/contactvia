/* ------------------------------

- ContactVia -


--------------------------------*/
import UIKit
import Parse
import MessageUI
import AudioToolbox
import GoogleMobileAds



// MARK: - CUSTOM FAVORITE CELL
class FavCell: UITableViewCell {
    /* Views */
    @IBOutlet var cardView: UIView!
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var fullNameLabel: UILabel!
    @IBOutlet var aboutTxt: UITextView!
    
    @IBOutlet var contactOutlet: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup views of the cell
        self.cardView.layer.cornerRadius = 10
        self.cardView.layer.shadowOffset = CGSizeMake(2, 2)
        self.cardView.layer.shadowOpacity = 0.8
        self.cardView.layer.shadowColor = superLightGray.CGColor
    }
    
}









// MARK: - FAVORITES CONTROLLER
class Favorites: UIViewController,
MFMailComposeViewControllerDelegate,
UIAlertViewDelegate,
GADBannerViewDelegate
{

    /* Views */
    @IBOutlet var favTableView: UITableView!
    
    // Ad banners properties
    var adMobBannerView = GADBannerView()
    

    /* Variables */
    var cardObj = PFObject(className: CARDS_CLASS_NAME)
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

    self.title = "Favorites"
    
    // Initialize ad banners
    initAdMobBanner()
    
    // Call query
    queryFavorites()
}
    

// MARK: - QUERY FAVORITES
func queryFavorites() {
    showHUD()
    favArray.removeAll()
    
    let query = PFQuery(className: FAVORITES_CLASS_NAME)
    query.whereKey(FAVORITES_CURRENT_USER, equalTo: PFUser.currentUser()! )
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            self.favArray = objects!
            self.favTableView.reloadData()
            self.hideHUD()
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}

    
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
}
func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return favArray.count
}
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("FavCell", forIndexPath: indexPath) as! FavCell
    
    var favClass = PFObject(className: FAVORITES_CLASS_NAME)
    favClass = favArray[indexPath.row]
    var cardPointer = favClass[FAVORITES_CARD] as! PFObject
    do { cardPointer = try cardPointer.fetchIfNeeded() } catch {}
    
    
    cell.contactOutlet.tag = indexPath.row
    
    // Get avatar image
    cell.avatarImage.layer.cornerRadius = cell.avatarImage.bounds.size.width/2
    let imageFile = cardPointer[CARDS_AVATAR] as? PFFile
    imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                cell.avatarImage.image = UIImage(data:imageData)
    }}}
    

    // Get other details
    cell.cityLabel.text = "\(cardPointer[CARDS_CITY]!)"
    cell.fullNameLabel.text = "\(cardPointer[CARDS_FULLNAME]!)"
    cell.aboutTxt.text = "\(cardPointer[CARDS_ABOUT]!)"
    
    // Get bkg Color
    let bkgColor = cardPointer[CARDS_BACKGROUND_COLOR] as! Int
    cell.cardView.backgroundColor = colorsArray[bkgColor]
    
    
return cell
}

    

// DELETE CELL BY SWIPING THE CELL LEFT
func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
}
func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == UITableViewCellEditingStyle.Delete {
        
        var favClass = PFObject(className: FAVORITES_CLASS_NAME)
        favClass = favArray[indexPath.row]
        
        // Delete Favorite on Parse
        favClass.deleteInBackgroundWithBlock {(success, error) -> Void in
            if error != nil {
                self.simpleAlert("\(error!.localizedDescription)")
        }}
        
        // Delete Favorite in the Array
        favArray.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    
    }
}

    
    
    
// MARK: - CONTACT USER BUTTON
@IBAction func contactButt(sender: AnyObject) {
    var favClass = PFObject(className: FAVORITES_CLASS_NAME)
    favClass = favArray[sender.tag]
    
    cardObj = PFObject(className: CARDS_CLASS_NAME)
    cardObj = favClass[FAVORITES_CARD] as! PFObject
    
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
    
    
// Email delegate
func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
    var outputMessage = ""
    switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue: outputMessage = "Mail cancelled"
        case MFMailComposeResultSaved.rawValue: outputMessage = "Mail saved"
        case MFMailComposeResultSent.rawValue: outputMessage = "Mail sent"
        case MFMailComposeResultFailed.rawValue: outputMessage = "Something went wrong with sending Mail, try again later."
    
    default: break }
    
    simpleAlert(outputMessage)
    dismissViewControllerAnimated(false, completion: nil)
}

    
    
    
// MARK: - REFRESH BUTTON
@IBAction func refreshButt(sender: AnyObject) {
    queryFavorites()
}
    

    
    
// MARK - AdMob BANNER METHODS
func initAdMobBanner() {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSizeMake(320, 50))
        adMobBannerView.frame = CGRectMake(0, view.frame.size.height, 320, 50)
        
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
        banner.frame = CGRectMake(0, view.frame.size.height, banner.frame.size.width, banner.frame.size.height)
        UIView.commitAnimations()
        banner.hidden = true
        
    }
    
    // Show the banner
    func showBanner(banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        
        // Move the banner on the bottom of the screen
        banner.frame = CGRectMake(view.frame.size.width/2 - banner.frame.size.width/2, view.frame.size.height - 44 - banner.frame.size.height,
            banner.frame.size.width, banner.frame.size.height)
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
