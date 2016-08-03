//
//  BookResultsContainer.swift
//  Marketplace
//
//  Created by Markim Shaw on 7/28/16.
//  Copyright © 2016 Markim Shaw. All rights reserved.
//

import UIKit

class BookResultsContainer: UIViewController {
    @IBOutlet weak var _unavailableView: UIView!

    @IBOutlet weak var _bookTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var _loadingView: UIView!
    @IBOutlet weak var _unavailableText: UILabel!
    var bookLink:String!
    var bookTitle:String!
    var bookType:String = "hardcover"
    var bookResultsTableViewController:BookResultsTableViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.bookType = "hardcover"
        self.title = self.bookTitle
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "to_BookResultsTableViewController"{
            self.bookResultsTableViewController = segue.destinationViewController as! BookResultsTableViewController
            //let destination = nav.topViewController as! BookResultsTableViewController
            self.bookResultsTableViewController.bookLink = self.bookLink
            self.bookResultsTableViewController.bookTitle = self.bookTitle
            self.bookResultsTableViewController.loadSearchData("hardcover")
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.checkAvailability), name: "availability", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.loadingView), name: "loading", object: nil)
            self.bookResultsTableViewController._bookTypeSegmentedControl = self._bookTypeSegmentedControl
                
            }
    }
    
    func loadingView(){
        self._loadingView.hidden = true
    }
    
    func checkAvailability(){
        if self.bookResultsTableViewController.unavailable == true {
            self._unavailableView.hidden = false
            self._unavailableText.text = "\(self.bookType) unavailable"
        }else {
            self._unavailableView.hidden = true
        }
    }

}

extension BookResultsContainer {
    
    @IBAction func refreshTable(sender: AnyObject) {
        
        
        
        switch (sender as! UISegmentedControl).selectedSegmentIndex {
        case 0:
            if self.bookResultsTableViewController.hardcoverSearchResults.count == 0 {
                self._loadingView.hidden = false
                self.bookType = "hardcover"
                //self._loadingView.hidden = false
                self.bookResultsTableViewController.loadSearchData("hardcover")
                
            }
            break
        case 1:
            if self.bookResultsTableViewController.paperbackSearchResults.count == 0 {
                self._loadingView.hidden = false
                self.bookType = "paperback"
                //self._loadingView.hidden = false
                self.bookResultsTableViewController.loadSearchData("paperback")
            }
            break
        default:
            break
        }
        
        
        self.bookResultsTableViewController.tableView.reloadData()
    }
    
    
   /* @IBAction func refreshTable(sender: AnyObject) {
        
        switch (sender as! UISegmentedControl).selectedSegmentIndex {
        case 0:
            if self.hardcoverSearchResults.count == 0 {
                self.loadSearchData("hardcover")
            }
            break
        case 1:
            if self.paperbackSearchResults.count == 0 {
                self.loadSearchData("paperback")
            }
            break
        default:
            break
        }
        
        self.tableView.reloadData()
    }*/
}

extension UITableView {
    
    func availability(b:BookResultsContainer){
        if b.bookResultsTableViewController.unavailable == true {
            b._unavailableView.hidden = false
            b._unavailableText.text = "\(b.bookType) unavailable"
        }else {
            b._unavailableView.hidden = true
        }
    }
}
