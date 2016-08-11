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
import SWXMLHash

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - UI Elements prefaced with _
    @IBOutlet weak var _searchTableView: UITableView!
    @IBOutlet weak var _searchTextField: UITextField!
    @IBOutlet weak var _searchBar: UISearchBar!
    @IBOutlet weak var _bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var _topResultImageView: UIImageView!
    
    
    //MARK: - Class Elements in camelCase
    var searchResults:[String] = []
    var searching:Bool!
    var device_token:String!
    var api_key = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false

        self.title = "Search"
        self.searching = false
        
        self._searchBar.showsCancelButton = true
        self._searchBar.delegate = self
        
        //Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.getApiKey), name: "getApiKey", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.postApiKey), name: "postApiKey", object: nil)
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 225.0/255.0, green: 33.0/255.0, blue: 55.0/255.0, alpha: 1.0)
    }

 
 
    func dismissKeyboard(){
        self._searchBar.endEditing(true)

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
    
    //This function is created since the device token is not set until after this view loads. So once the device token is called send a notification to this View to make the POST call to the API
    func postApiKey(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.device_token = appDelegate.deviceToken
        Alamofire.request(.POST, "https://fathomless-gorge-53738.herokuapp.com/api", parameters: ["device_id":self.device_token!])
    }
    
    func getApiKey(){
        Alamofire.request(.GET, "https://fathomless-gorge-53738.herokuapp.com/api", parameters: ["device_id":self.device_token!]).responseJSON(completionHandler: {
            response in
            print(response.description)
            let responseJSON = try! NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! Array<Dictionary<NSObject,AnyObject>>
            print(responseJSON)
            self.api_key = responseJSON[0]["key"] as! String
            
        })
    }
    
    func search(){
        if self._searchBar.text!.characters.count > 3{

            self.searching = true
            
            Alamofire.request(.GET, "https://www.goodreads.com/search/index.xml?", parameters: ["key":"Ojs0mDZl5mhGJo3hoHCeQ", "q":self._searchBar.text!]).response(completionHandler: {
                request, response, data, error in
                let data_string = NSString.init(data: data!, encoding: NSUTF8StringEncoding)
                self.searchResults = []
                self._searchTableView.reloadData()
                let search_results_xml = SWXMLHash.parse((data_string! as String))
                
                for (_,work) in search_results_xml["GoodreadsResponse"]["search"]["results"]["work"].enumerate() {
                    if !self.searchResults.contains((work["best_book"]["author"]["name"].element?.text!)!){
                        let authorname = (work["best_book"]["author"]["name"].element?.text!)!
                        let bookname = (work["best_book"]["title"].element?.text!)!
                        
                        if bookname.containsString(self._searchBar.text!){
                            self.searchResults += [bookname]
                        } else {
                            self.searchResults += [authorname]
                        }
                    }
                    
                    self._searchTableView.reloadData()
                }

            })
        }
    }

    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.searchResults = []
            self._searchTableView.reloadData()
        }
        self.search()
    }
}
extension SearchViewController{
    
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
        text.text = self.searchResults[indexPath.row]
        
        return cell
    }
}
