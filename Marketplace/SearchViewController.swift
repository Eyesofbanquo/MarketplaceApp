//
//  SearchViewController.swift
//  Marketplace
//
//  Created by Markim Shaw on 7/25/16.
//  Copyright © 2016 Markim Shaw. All rights reserved.
//

/* Notes of importance:
 
 1) When the search button is pressed the only action called in this file is to begin the segue to the SearchResultsTableViewController. That controller hanldes the API calls. This controller is specifically for getting the text information from _searchTextField
 */

import UIKit
import Alamofire
import CoreLocation
import SWXMLHash

class SearchViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - UI Elements prefaced with _
    @IBOutlet weak var _searchTableView: UITableView!
    @IBOutlet weak var _searchTextField: UITextField!
    @IBOutlet weak var _searchBar: UISearchBar!
    @IBOutlet weak var _bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var _topResultImageView: UIImageView!
    
    
    //MARK: - Class Elements in camelCase
    let locationManager = CLLocationManager()
    var searchResults:[String] = []
    var searching:Bool!
    var api_key = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        //view.addGestureRecognizer(tap)
        
        Alamofire.request(.GET, "https://fathomless-gorge-53738.herokuapp.com/api").responseJSON(completionHandler: {
            response in
            do {
                let responseDict = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! Array<Dictionary<NSObject, AnyObject>>
                self.api_key = responseDict[0]["key"] as! String
                print(self.api_key)
            } catch {
                
            }
            
        })
        
        self.title = "Marketplace"
        self.searching = false
        
        self._searchBar.showsCancelButton = true
        self._searchBar.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.requestWhenInUseAuthorization()
        //locationManager.startUpdatingLocation()
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.loadImage), name: "load_image", object: nil)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
        if keyboardSize.height == offset.height {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y -= keyboardSize.height
            })
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        self.view.frame.origin.y += keyboardSize.height
    }
 
 
    func dismissKeyboard(){
        self._searchBar.endEditing(true)

    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]

        self.navigationController?.navigationBar.barTintColor = UIColor(red: 225.0/255.0, green: 33.0/255.0, blue: 55.0/255.0, alpha: 1.0)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {placemarks,errors in
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                self.getLocationInformation(pm)
            }
        })
    }
    
    func getLocationInformation(placemark: CLPlacemark?){
        if placemark != nil {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            //print(placemark!.locality!)
            //print(placemark!.postalCode!)
            print(placemark!.administrativeArea!) // State information
            //User coredata instead
            if NSUserDefaults.standardUserDefaults().valueForKey("location") == nil {
                 NSUserDefaults.standardUserDefaults().setValue(placemark!.administrativeArea!, forKeyPath: "location")
            }
           
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "to_SearchResultsTableViewController" {
            if let searchText = self._searchBar.text {
                let destinationViewController = segue.destinationViewController as! SearchResultsTableViewController
                destinationViewController.searchText = searchText
            }
        }
    }
    
    @IBAction func unwindFromSearchView(segue:UIStoryboardSegue){
        self._searchTextField.text = ""
    }
    

}

//* For handling the search API with goodreads
extension SearchViewController {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.performSegueWithIdentifier("to_SearchResultsTableViewController", sender: self)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searching = false
        self.dismissKeyboard()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        self.dismissKeyboard()
    }
    
    func search(){
        if self._searchBar.text!.characters.count > 1{

            self.searching = true
            
            Alamofire.request(.GET, "https://www.goodreads.com/search/index.xml?", parameters: ["key":"Ojs0mDZl5mhGJo3hoHCeQ", "q":self._searchBar.text!]).response(completionHandler: {
                request, response, data, error in
                let data_string = NSString.init(data: data!, encoding: NSUTF8StringEncoding)
                self.searchResults = []
                self._searchTableView.reloadData()
                let search_results_xml = SWXMLHash.parse((data_string! as String))
                let size = search_results_xml["GoodreadsResponse"]["search"]["results"]["work"].children.count
                
                for (index,work) in search_results_xml["GoodreadsResponse"]["search"]["results"]["work"].enumerate() {
                    /*if index == 1 {
                        self._topResultImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: (work["best_book"]["image_url"].element?.text!)!)!)!)
                    }*/
                    if !self.searchResults.contains((work["best_book"]["author"]["name"].element?.text!)!){
                        self.searchResults += [(work["best_book"]["author"]["name"].element?.text!)!]
                        
                    }
                    
                    self._searchTableView.reloadData()
                }

            })
        }
    }

    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        /*if self.searching == false {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.search), userInfo: nil, repeats: false)
        }*/
        
        self.search()

        
    }
}

/* API CALLS */
extension SearchViewController {
    
    
}

extension SearchViewController{
    
    //Helper function for setting the current image
    func loadImage(){
        
    }
    
    //When the user selects an item from the list make sure you set the search text to match that item
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("search_results", forIndexPath: indexPath)
        let text = cell.viewWithTag(1) as! UILabel
        text.text = self.searchResults[indexPath.row]
        self._searchBar.text! = self.searchResults[indexPath.row]
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.reloadData()
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("search_results", forIndexPath: indexPath)
        let text = cell.viewWithTag(1) as! UILabel
        
        if let search_text = text.text{
            if self.searchResults[indexPath.row].containsString(self._searchBar.text!){
                let mutableString = NSMutableAttributedString(string: self.searchResults[indexPath.row], attributes: [:])
                mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: 0, length: self._searchBar.text!.characters.count))
                //text.text = self.searchResults[indexPath.row]
                text.attributedText = mutableString
            } else {
               text.text = self.searchResults[indexPath.row]
            }
        }
        
        
        
        return cell
    }
}
