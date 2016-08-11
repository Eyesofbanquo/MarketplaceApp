//
//  SearchResultsTableViewController.swift
//  Marketplace
//
//  Created by Markim Shaw on 7/26/16.
//  Copyright © 2016 Markim Shaw. All rights reserved.
//

import UIKit
import Alamofire

class SearchResultsTableViewController: UITableViewController {
    //MARK: - From Segue
    var searchText:String!
    
    //MARK: - Class elements
    var searchResults:[Book] = []
    var pageNumber:Int = 1
    
    var device_token:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        let app_delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        device_token = app_delegate.deviceToken!
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.loadSearchData), name: "loadSearchData", object: nil)
        
        self.requestSearch()
    }
    
    override func viewWillAppear(animated:Bool){
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationItem.title = "Search Results"
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.searchResults.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("search_results", forIndexPath: indexPath)

        // Cell information:
        // Tag 1 => Image
        // Tag 2 => Title
        // Tag 3 => Author
        let image = cell.viewWithTag(1) as! UIImageView
        let title = cell.viewWithTag(2) as! UILabel
        
        title.text = self.searchResults[indexPath.row]._title!
        image.image = self.searchResults[indexPath.row].image

        return cell
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "to_bookReseultsContainer"{
            let destination = segue.destinationViewController as! BookResultsContainer
            if let cell = sender as? UITableViewCell{
                if let indexPath = tableView.indexPathForCell(cell){
                    let selected_book_link = self.searchResults[indexPath.row]._link!
                    let selected_book_title = self.searchResults[indexPath.row]._title!
                    destination.bookLink = selected_book_link
                    destination.bookTitle = selected_book_title
                }
                
            }
        }
    }
 

}

/* API CALLS */
extension SearchResultsTableViewController {
    func requestSearch(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            Alamofire.request(.POST, "https://fathomless-gorge-53738.herokuapp.com/search", parameters: ["keywords":self.searchText, "device_id":self.device_token])
        })
    }
    
    func loadSearchData(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            Alamofire.request(.GET, "https://fathomless-gorge-53738.herokuapp.com/search", parameters: ["device_id":self.device_token]).responseJSON(completionHandler: {
                response in
                do {
                    let book_search_results_array = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! Array<Dictionary<NSObject, AnyObject>>
                    //If this is nil then that means there was an error so you should not continue with trying to parse results. Instead, tell the user that the information does not exist and allow them to search again
                    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    for i in 0..<book_search_results_array.count{
                        let book_title = book_search_results_array[i]["title"] as! String
                        let book_link = book_search_results_array[i]["link"] as! String
                        let book_img = book_search_results_array[i]["img"] as! String
                        
                        let newBook = Book(title: book_title, link: book_link, img: book_img)
                        self.searchResults += [newBook]
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                            let image_data = NSData(contentsOfURL: NSURL(string: book_img)!)
                            let image = UIImage(data: image_data!)
                            
                            dispatch_async(dispatch_get_main_queue()){
                                newBook.image = image
                                self.tableView.reloadData()
                            }
                            
                        })
                    }
                    //})
                } catch {
                    print(error)
                }
                self.tableView.reloadData()
            })
        }
        
    }
}
