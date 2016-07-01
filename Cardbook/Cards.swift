/* ------------------------------

- ContactVia -


--------------------------------*/

import UIKit
import Parse
import AudioToolbox
import GoogleMobileAds



// MARK: - CUSTOM CARD CELL
class CardCell: UICollectionViewCell {
    /* Views */
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userFullNameLabel: UILabel!
    @IBOutlet var userCityLabel: UILabel!
}








// MARK: - CARDS CONTROLLER
class Cards: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate,
GADBannerViewDelegate
{

    /* Views */
    @IBOutlet var cardsCollView: UICollectionView!
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchTxt: UITextField!
    @IBOutlet var topicsTableView: UITableView!
    @IBOutlet var searchOutlet: UIBarButtonItem!
    
    //Ad banners properties
    var adMobBannerView = GADBannerView()
    
    
    
    
    /* Variables */
    var cardsArray = [PFObject]()
    var topicsArray = [PFObject]()
    var cardCellSize = CGSize()
    
    var hashtagStr = ""
    var hashtagsArray = NSMutableArray()
    var allTopicsStr = ""
    
    
    
    
    
    
override func viewWillAppear(animated: Bool) {
    if hashtagStr != "" {
        makeSearchByHashtag(hashtagStr)
    }
    
    // OPEN LOGIN CONTROLLER (You're not logged in)
    if PFUser.currentUser() == nil {
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
        presentViewController(loginVC, animated: true, completion: nil)
    }
    
}
    
override func viewDidLoad() {
        super.viewDidLoad()
   
    self.title = "Latest Cards"
    
    // Initialize ad banners
    initAdMobBanner()
    
    
    // Resize card cell size based on device screen size
    if UIScreen.mainScreen().bounds.size.width == 320 {
        //iPhone 4 / 5
        cardCellSize = CGSizeMake(138, 162)
    } else if UIScreen.mainScreen().bounds.size.width == 375 {
        // iPhone 6
        cardCellSize = CGSizeMake(160, 188)
    } else if UIScreen.mainScreen().bounds.size.width == 414 {
        // iPhone 6+
        cardCellSize = CGSizeMake(180, 211)
    } else if UIScreen.mainScreen().bounds.size.width == 768 {
        // iPad
        cardCellSize = CGSizeMake(230, 270)
    }
    
    
    // Hide the searchView
    searchView.frame.origin.y = view.frame.size.height
    
    // Round views corners
    topicsTableView.layer.cornerRadius = 8
    
    queryUsers()
}

func queryUsers() {
    cardsArray.removeAll()
    showHUD()
    
    let query = PFQuery(className: CARDS_CLASS_NAME)
    query.orderByDescending("createdAt")
    query.findObjectsInBackgroundWithBlock { (objects, error) in
        if error == nil {
            self.cardsArray = objects!
            self.cardsCollView.reloadData()
            self.hideHUD()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    
    
    
    
// MARK: - COLLECTION VIEW DELEGATES
func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
}

func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return cardsArray.count
}

func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CardCell", forIndexPath: indexPath) as! CardCell
    
    var cardsClass = PFObject(className: CARDS_CLASS_NAME)
    cardsClass = cardsArray[indexPath.row]

    cell.userFullNameLabel.text = "\(cardsClass[CARDS_FULLNAME]!)"
    cell.userCityLabel.text = "\(cardsClass[CARDS_CITY]!)"
    
    cell.userImage.layer.cornerRadius = cell.userImage.bounds.size.width/2
    cell.layer.cornerRadius = 6
    
    // Get bkg Color
    let bkgColor = cardsClass[CARDS_BACKGROUND_COLOR] as! Int
    cell.backgroundColor = colorsArray[bkgColor]
    
    // Get User image
    cell.userImage.image = UIImage(named: "logo")
    let imageFile = cardsClass[CARDS_AVATAR] as? PFFile
    imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                cell.userImage.image = UIImage(data:imageData)
    }}}
    

    
return cell
}

func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return cardCellSize
}
    
    
// MARK: - CARD TAPPED -> SHOW CARD DEATILS
func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    var cardsClass = PFObject(className: CARDS_CLASS_NAME)
    cardsClass = cardsArray[indexPath.row]
    
    let cdVC = storyboard?.instantiateViewControllerWithIdentifier("CardDetails") as! CardDetails
    cdVC.cardObj = cardsClass
    navigationController?.pushViewController(cdVC, animated: true)
}
   

    
    
// MARK: - REFRESH BUTTON
@IBAction func refreshButt(sender: AnyObject) {
    self.title = "Latest Cards"
    queryUsers()
}
    
    
    
    
    
// MARK: - OPEN SEARCH VIEW BUTTON
@IBAction func openSearchViewButt(sender: AnyObject) {
    // Get the topics stored in Topics Class
    let query = PFQuery(className: TOPICS_CLASS_NAME)
    query.findObjectsInBackgroundWithBlock { (objects, error) in
        if error == nil {
            self.topicsArray = objects!
            self.getTopics()
            print("\(self.topicsArray)")
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }}
    
    // Shoe searchView
    showSearchView()
}

func getTopics() {
    allTopicsStr = ""
    hashtagsArray.removeAllObjects()
    
    // Build a unique string out of all the stored Topics (hashtags)
    for i in 0..<topicsArray.count {
      var topicsClass = PFObject(className: TOPICS_CLASS_NAME)
      topicsClass = topicsArray[i]
         allTopicsStr += "\(topicsClass[TOPICS_TOPIC]!)"
    }
    
    // Splist the big string
    var tempArray = allTopicsStr.componentsSeparatedByString("#")
    
    // Build the hashtagsArray by the tempArray
     for t in 0..<tempArray.count {
        hashtagsArray.addObject("#\(tempArray[t])")
     }
    hashtagsArray.removeObjectAtIndex(0)
    
    let finalArray = getCountAndRemoveMultiples(hashtagsArray)
    hashtagsArray = finalArray
    // print("HASHTAGS: \(hashtagsArray)")
    
    
    // Finally reload tableView
    topicsTableView.reloadData()
}
    
 
    
    
// MARK: - CHECK FOR IDENTICAL TOPICS -> IF THEY'RE PRESENT, REMOVE THEM
func getCountAndRemoveMultiples(array: NSMutableArray) -> NSMutableArray {
    let newArray = NSMutableArray(array: array)
    
    for i in 0..<newArray.count {
      let string = "\(newArray[i])"
        for j in i+1..<newArray.count {
           if string == "\(newArray[j])" {
             newArray.removeObjectAtIndex(j)
           }
        }
    }
    let finalArray = newArray
    
return finalArray
}
    

 
// MARK: - SHOW/HIDE SEARCHVIEW (ANIMATIONS)
func showSearchView() {
    searchTxt.text = ""
    searchView.alpha = 0
    self.title = "Search Cards"
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(dismissSearchView))
    navigationItem.leftBarButtonItem?.tintColor = superLightGray
        
        
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.searchView.frame.origin.y = 0
    }, completion: { (finished: Bool) in
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.searchView.alpha = 1
        }, completion: { (finished: Bool) in  })
    })
}
    
func hideSearchView() {
    searchView.alpha = 0
    searchTxt.resignFirstResponder()
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: #selector(openSearchViewButt(_:)))
    navigationItem.leftBarButtonItem?.tintColor = superLightGray
        
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.searchView.frame.origin.y = self.view.frame.size.height
    }, completion: { (finished: Bool) in  })
}
    
    
    
// MARK: - DISMISS SEARCH VIEW BUTTON
func dismissSearchView() {
    hideSearchView()
    self.title = "Latest Cards"
}
    
    
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
}
func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hashtagsArray.count
}
    
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 

    cell.textLabel?.text = "\(hashtagsArray[indexPath.row])"
    
return cell
}


// CELL HAS BEEN TAPPED (Filter results by hastag in the tapped cell)
func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    
    let hStr = cell!.textLabel!.text!
    makeSearchByHashtag(hStr.lowercaseString)
    print("HASHTAG STRING: \(hStr)")
}


    
 
// MARK: - TEXTFIELD DELEGATE -> SEARCH FOR USER'S FULL NAME
func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    searchByUserFullName(searchTxt.text!)
    
return true
}

func textFieldShouldClear(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    textField.text = ""
return false
}
    
    
    
    
    
// MARK: - MAKE SEARCH BY SELECTED OR TYPED TERM
func makeSearchByHashtag(hashtag: String) {
    cardsArray.removeAll()
    showHUD()
    searchTxt.resignFirstResponder()
    
    let query = PFQuery(className: CARDS_CLASS_NAME)
    query.whereKey(CARDS_ABOUT, containsString: hashtag)
    query.limit = 20
    
    // Query block
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            self.cardsArray = objects!
            if self.cardsArray.count == 0 {
                self.title = "No Cards Found"
            }
            
            self.cardsCollView.reloadData()
            self.hideHUD()
                
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
    
    
    hideSearchView()
    self.title = "Cards Found"
}


    
    
   
// MARK: - SEARCH BY USER'S FULLNAME
func searchByUserFullName(name: String) {
    cardsArray.removeAll()
    showHUD()
    searchTxt.resignFirstResponder()
        
    let query = PFQuery(className: CARDS_CLASS_NAME)
    query.whereKey(CARDS_FULLNAME, containsString: name)
    query.limit = 20
        
    // Query block
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            self.cardsArray = objects!
            if self.cardsArray.count == 0 {
                self.title = "No Cards Found"
            }
                
            self.cardsCollView.reloadData()
            self.hideHUD()
                
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
        
        
    hideSearchView()
    self.title = "Cards Found"
}

    
    
    
 
    
    
// MARK: - AdMob BANNER METHODS
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
