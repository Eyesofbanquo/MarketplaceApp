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
    //var audiobookSearchResults:NSObject!
    
    var device_token:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bookType = "hardcover"

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.loadSearchData), name: "loadBookData", object: nil)
    }
    
    override func viewWillAppear(animated:Bool){
        super.viewWillAppear(animated)
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
            if self._hpbSelectSwitch.on == true {
                let filteredBooks = self.filteredBooks(self.hardcoverSearchResults)
                return filteredBooks.count
            } else {
               return self.hardcoverSearchResults.count
            }
            
        case 1:
            if self._hpbSelectSwitch.on == true {
                let filteredBooks = self.filteredBooks(self.paperbackSearchResults)
                return filteredBooks.count
            } else {
                return self.paperbackSearchResults.count
            }
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
            if self._hpbSelectSwitch.on == true{
                
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
            if self._hpbSelectSwitch.on == true{
                
                let filteredBooks = self.filteredBooks(self.paperbackSearchResults)
                seller.text = filteredBooks[indexPath.row]._seller!
                price.text = filteredBooks[indexPath.row]._price!
                location.text = filteredBooks[indexPath.row]._location!
                
            } else {
                seller.text = self.paperbackSearchResults[indexPath.row]._seller!
                price.text = self.paperbackSearchResults[indexPath.row]._price!
                location.text = self.paperbackSearchResults[indexPath.row]._location!
            }
            break
        default:
            seller.text = "The"
            price.text = "Picture"
            location.text = "Of Dorian Gray"
        }

        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "to_BookDetailViewController"{
            let destination = segue.destinationViewController as! BookDetailViewController
            if let cell = sender as? UITableViewCell{
                if let indexPath = tableView.indexPathForCell(cell){
                    destination.bookTitle = self.bookTitle
                    if self.bookType == "hardcover" {
                        if self._hpbSelectSwitch.on {
                            let filteredBooks = self.filteredBooks(self.hardcoverSearchResults)
                            destination.bookLocation = filteredBooks[indexPath.row]._seller!
                        } else {
                            destination.bookLocation = self.hardcoverSearchResults[indexPath.row]._seller!
                        }
                    } else {
                        if self._hpbSelectSwitch.on {
                            let filteredBooks = self.filteredBooks(self.paperbackSearchResults)
                            destination.bookLocation = filteredBooks[indexPath.row]._seller!
                        } else {
                            destination.bookLocation = self.paperbackSearchResults[indexPath.row]._seller!
                        }
                    }
                }
                
            }
        }
    }
    

}

extension BookResultsTableViewController {
    func filteredBooks(originalBooks:[Book]) -> [Book]{
        let filteredBooks = originalBooks.filter({
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
        NSNotificationCenter.defaultCenter().postNotificationName("availability", object: self)
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
        
        //self.tableView.reloadData()
    }
}

extension BookResultsTableViewController {
    /* The search_results_array returns JSON with 3 keys - Hardcover, Paperback, Audiobook
        In each Key there is an array that holds the book information (Seller, Price, Location) */
    
    func postSearchData(bookType:String){
        let searchURL = "https://fathomless-gorge-53738.herokuapp.com/book"
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            Alamofire.request(.POST, searchURL, parameters: ["link":self.bookLink, "book_type":bookType, "device_id":self.device_token])
        })
        
    }
    func loadSearchData(){
        let searchURL = "https://fathomless-gorge-53738.herokuapp.com/book"
            Alamofire.request(.GET, searchURL, parameters: ["device_id":self.device_token]).responseJSON(completionHandler: {
                response in
                dispatch_async(dispatch_get_main_queue(), {
                    do {
                        let search_results_array = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! Array<Dictionary<NSObject, AnyObject>>
                        let dictionary = search_results_array
                        if dictionary.count == 0 {
                            
                            self.unavailable = true
                            NSNotificationCenter.defaultCenter().postNotificationName("availability", object: self)
                            
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
                            if i == dictionary.count-1{
                                NSNotificationCenter.defaultCenter().postNotificationName("loading", object: self)
                            }
                        }
                    } catch {
                        
                    }
                    self.tableView.reloadData()
                })
        })
       
    }

}
