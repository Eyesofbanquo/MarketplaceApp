//
//  SearchResultsTableViewController.swift
//  Marketplace
//
//  Created by Markim Shaw on 7/25/16.
//  Copyright © 2016 Markim Shaw. All rights reserved.
//

import UIKit
import Alamofire

class BookResultsTableViewController: UITableViewController {

    @IBOutlet weak var _bookTypeSegmentedControl: UISegmentedControl!
   
    @IBOutlet weak var _hpbSelectSwitch: UISwitch!
    
    //MARK: - Class Elements
    var bookLink:String!
    var bookTitle:String!
    var bookType:String!
    var unavailable:Bool = false
    var hardcoverSearchResults:[Book] = []
    var paperbackSearchResults:[Book] = []
    var audiobookSearchResults:NSObject!
    var isCurrentlySearching:Bool!
    
    var device_token:String = "<5a0b50fe e241aba2 4285b990 40d374e9 4ebff20e cb3fc17f b5ebed36 2ce6514b>"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bookType = "hardcover"
        //self._hpbSelectSwitch.enabled = false
        //self.loadSearchData(bookType)
        //self.postSearchData(self.bookType)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.loadSearchData), name: "loadBookData", object: nil)
    }
    
    override func viewWillAppear(animated:Bool){
        super.viewWillAppear(animated)
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        //self.loadSearchData(bookType)
        self.title = self.bookTitle

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch self._bookTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            if self._hpbSelectSwitch.enabled == true {
                let filteredBooks = self.filteredBooks(self.hardcoverSearchResults)
                return filteredBooks.count
            } else {
               return self.hardcoverSearchResults.count
            }
            
        case 1:
            return self.paperbackSearchResults.count
        default:
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("book_information", forIndexPath: indexPath)

        // Cell information:
        // Tag 1 => Seller
        // Tag 2 => Price
        // Tag 3 => Location
        
        let seller = cell.viewWithTag(1) as! UILabel
        let price = cell.viewWithTag(2) as! UILabel
        let location = cell.viewWithTag(3) as! UILabel
        
        switch self._bookTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            if self._hpbSelectSwitch.enabled == true{
                
                let filteredBooks = self.filteredBooks(self.hardcoverSearchResults)
                seller.text = filteredBooks[indexPath.row]._seller!
                price.text = filteredBooks[indexPath.row]._price!
                location.text = filteredBooks[indexPath.row]._location!
                
            } else {
                seller.text = self.hardcoverSearchResults[indexPath.row]._seller!
                price.text = self.hardcoverSearchResults[indexPath.row]._price!
                location.text = self.hardcoverSearchResults[indexPath.row]._location!
            }
            
            break
        case 1:
            seller.text = self.paperbackSearchResults[indexPath.row]._seller!
            price.text = self.paperbackSearchResults[indexPath.row]._price!
            location.text = self.paperbackSearchResults[indexPath.row]._location!
            break
        default:
            seller.text = "The"
            price.text = "Picture"
            location.text = "Of Dorian Gray"
        }

        return cell
    }
    
    
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "to_BookDetailViewController"{
            let destination = segue.destinationViewController as! BookDetailViewController
            //let destination = nav.topViewController as! BookResultsTableViewController
            if let cell = sender as? UITableViewCell{
                if let indexPath = tableView.indexPathForCell(cell){
                    destination.bookTitle = self.bookTitle
                    //let selected_book_link = self.searchResults[indexPath.row]._link!
                    //let selected_book_title = self.searchResults[indexPath.row]._title!
                    //destination.bookLink = selected_book_link
                    //destination.bookTitle = selected_book_title
                }
                
            }
            
            //let link = self.searchResults[indexPath.row]
        }
    }
    

}

extension BookResultsTableViewController {
    func filteredBooks(originalBooks:[Book]) -> [Book]{
        let filteredBooks = self.hardcoverSearchResults.filter({
            (filteredBook) in
            if ((filteredBook._seller?.containsString("HPB")) == true) {
                return true
            } else {
                return false
            }
        })
        return filteredBooks
    }
    
    @IBAction func enableHPBMode(sender: AnyObject) {
        /*if (sender as! UISwitch).enabled {
            self.tableView.reloadData()
        }*/
        NSNotificationCenter.defaultCenter().postNotificationName("availability", object: self)
        self._hpbSelectSwitch.enabled = !self._hpbSelectSwitch.enabled
        self.tableView.reloadData()
    }
    
}

extension BookResultsTableViewController {
    
    @IBAction func refreshTable(sender: AnyObject) {
        
        switch self._bookTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            if self.hardcoverSearchResults.count == 0{
                self.bookType = "hardcover"
                self.loadSearchData()
            }
            break
        case 1:
            if self.paperbackSearchResults.count == 0{
                self.bookType = "paperback"
                self.loadSearchData()
            }
            break
        default:
            break
        }
        
        self.tableView.reloadData()
    }
}

extension BookResultsTableViewController {
    /* The search_results_array returns JSON with 3 keys - Hardcover, Paperback, Audiobook
        In each Key there is an array that holds the book information (Seller, Price, Location) */
    
    func postSearchData(bookType:String){
        var searchURL = "https://fathomless-gorge-53738.herokuapp.com/book"
        if bookType == "paperback" {
            
        }
        
        Alamofire.request(.POST, searchURL, parameters: ["link":self.bookLink, "book_type":bookType, "device_id":self.device_token])
    }
    func loadSearchData(){
        //self.isCurrentlySearching = true
        var searchURL = "https://fathomless-gorge-53738.herokuapp.com/book"
        if self.bookType == "paperback" {
            
        }
        Alamofire.request(.GET, searchURL, parameters: ["device_id":self.device_token]).responseJSON(completionHandler: {
            response in
            do {
                
                //self.unavailable = false
                let search_results_array = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! Array<Dictionary<NSObject, AnyObject>>
                let dictionary = search_results_array
                
                if dictionary.count == 0 {
                    self.unavailable = true
                    NSNotificationCenter.defaultCenter().postNotificationName("availability", object: self)
                    return
                } else {
                    self.unavailable = false
                    NSNotificationCenter.defaultCenter().postNotificationName("availability", object: self)
                }

                for i in 0..<dictionary.count {
                    let newBook = Book(seller: dictionary[i]["seller"] as! String, price: dictionary[i]["price"] as! String, location: dictionary[i]["location"] as! String)
                    
                    switch self.bookType {
                    case "hardcover":
                        self.hardcoverSearchResults += [newBook]
                        break
                    case "paperback":
                        self.paperbackSearchResults += [newBook]
                        break
                    default:
                        break
                    }
                    
                    if i == dictionary.count - 1 {
                        NSNotificationCenter.defaultCenter().postNotificationName("loading", object: self)
                    }
                    self.tableView.reloadData()
                    
                }
            } catch {
                //self.unavailable = true
                
                //self.tableView.avail
                print(error)
                return

            }
            self.isCurrentlySearching = false
        })
        
    }

}
