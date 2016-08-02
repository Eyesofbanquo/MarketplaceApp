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

class SearchViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - UI Elements prefaced with _
    @IBOutlet weak var _searchTableView: UITableView!
    @IBOutlet weak var _searchTextField: UITextField!
    @IBOutlet weak var _searchBar: UISearchBar!
    @IBOutlet weak var _bottomConstraint: NSLayoutConstraint!
    
    //MARK: - Class Elements in camelCase
    let locationManager = CLLocationManager()
    var searchResults:[String] = []
    var searching:Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Marketplace"
        self.searching = false
        
        self._searchBar.showsCancelButton = true
        self._searchBar.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.requestWhenInUseAuthorization()
        //locationManager.startUpdatingLocation()
    
        // Do any additional setup after loading the view.
        
        /*NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)*/
    }
    
    /*func keyboardWillShow(notification: NSNotification) {
        //To retrieve keyboard size, uncomment following line
        //let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        self._bottomConstraint.constant = 260
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //To retrieve keyboard size, uncomment following line
        //let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        self._bottomConstraint.constant = 175
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }*/
    
    
    func dismissKeyboard(){
        self._searchTextField.endEditing(true)

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
            //print(placemark!.country!)
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
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searching = false
        self.searchResults = []
        self._searchTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        print("done?")
    }
    
    func search(){
        if self._searchBar.text!.characters.count > 3{
            self.searchResults = []
            self._searchTableView.reloadData()
            self.searching = true
            Alamofire.request(.GET, "https://fathomless-gorge-53738.herokuapp.com/quick-search", parameters: ["q":self._searchBar.text!]).responseJSON(completionHandler: {
                response in
                do {
                    //if self.searching == true {
                    let search_results_array = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! Array<Dictionary<NSObject, AnyObject>>
                    //let search_results = search_results_array[0]
                    for i in 0..<search_results_array.count {
                        self.searchResults += [search_results_array[i]["item" ] as! String]
                        self._searchTableView.reloadData()
                        
                        if i == search_results_array.count - 1 {
                            self.searching = false
                        }
                    }
                    //}
                    
                } catch{
                    print(error)
                }
                
            })
        }
    }

    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if self.searching == false {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.search), userInfo: nil, repeats: false)
        }
        
        if self.searchResults.count > 20 {
            self.searchResults = []
            
        }
        self._searchTableView.reloadData()
    }
}

extension SearchViewController{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("search_results", forIndexPath: indexPath)
        let text = cell.viewWithTag(1) as! UILabel
        
        text.text = self.searchResults[indexPath.row]
        
        return cell
    }
}
